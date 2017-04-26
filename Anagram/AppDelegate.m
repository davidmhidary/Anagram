//
//  AppDelegate.m
//  Anagram
//
//  Created by Ashok Choudhary on 05/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "AppDelegate.h"
#import "BeginVC.h"
#import "SplashVC.h"
#import "NSString+MD5ofString.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    
    [Fabric with:@[[Crashlytics class]]];
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    SplashVC *vc=[[SplashVC alloc]init];
    UINavigationController *nvc=[[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController=nvc;
    nvc.navigationBarHidden=YES;
    [self.window makeKeyAndVisible];
    self.currentUser=[ObjUser currentObject];
    [self doXmppDefaultWork];
    
    [self setValuesInUserDefaults];

    if (launchOptions) {
        
//       NSDictionary *dict=[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
      //[self acceptTheUserRequestHere:dict];
    }
    
    [self doNotificationsStuffHere];

    [application setStatusBarHidden:YES];
    application.idleTimerDisabled=YES;
    
    
    
//        NSArray *fontFamilies = [UIFont familyNames];
//        for (int i = 0; i < [fontFamilies count]; i++)
//        {
//            NSString *fontFamily = [fontFamilies objectAtIndex:i];
//            NSArray *fontNames = [UIFont fontNamesForFamilyName:fontFamily];
//            NSLog (@"%@: %@", fontFamily, fontNames);
//        }
    
    return YES;
}

-(void)doNotificationsStuffHere
{
    //Here we are just going to create the actions for the category.

    
         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
//            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
        }
        
     
    /*
    UIMutableUserNotificationAction *acceptAction = [self createAction];
    UIMutableUserNotificationAction *laterAction = [self createLaterAction];
    //Creating the category and assigning the actions:
    UIMutableUserNotificationCategory *acceptCategory = [self createCategory:@[acceptAction, laterAction]];
    //Register the categories
    [self registerCategorySettings:acceptCategory];
    */
  
}



//Create a category
- (UIMutableUserNotificationCategory *)createCategory:(NSArray *)actions {
    UIMutableUserNotificationCategory *acceptCategory = [[UIMutableUserNotificationCategory alloc] init];
    acceptCategory.identifier = @"INVITE_CATEGORY";
    
    [acceptCategory setActions:actions forContext:UIUserNotificationActionContextDefault];
    
    return acceptCategory;
}

//Register your settings for that category
- (void)registerCategorySettings:(UIMutableUserNotificationCategory *)category {
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    NSSet *categories = [NSSet setWithObjects:category, nil];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

//Create Actions Methods
- (UIMutableUserNotificationAction *)createAction {
    
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    
    // If YES requires passcode
    acceptAction.authenticationRequired = NO;
    
    return acceptAction;
}

- (UIMutableUserNotificationAction *)createLaterAction {
    
    UIMutableUserNotificationAction *laterAction = [[UIMutableUserNotificationAction alloc] init];
    laterAction.identifier = @"LATER_IDENTIFIER";
    laterAction.title = @"Not Now";
    
    laterAction.activationMode = UIUserNotificationActivationModeBackground;
    laterAction.destructive = NO;
    laterAction.authenticationRequired = NO;
    
    return laterAction;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData* )deviceToken
{
    NSString * StrToken = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString: @"<" withString: @""]
                            stringByReplacingOccurrencesOfString: @">" withString: @""]
                           stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    NSLog(@"Device Token %@",StrToken);
    
    self.strToken=StrToken;

    [self registerDeviceToken:StrToken];
    
 }

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Device Token %@",userInfo);
  
    // this code is commented now and
    /*
    if (application.applicationState!=UIApplicationStateActive) {
            [self acceptTheUserRequestHere:userInfo];
        
    }
    else if (application.applicationState==UIApplicationStateActive)
    {
        if (self.messageNotification) {
             [self.messageNotification.view removeFromSuperview];
     }
      self.messageNotification=[[AcceptTurnBasedPopUpVC alloc]initWithNibName:@"AcceptTurnBasedPopUpVC" bundle:nil ];
      self.messageNotification.view.frame=CGRectMake(0, 0, App_Delegate.window.frame.size.width, 134);
      self.messageNotification.dictPayload=userInfo;
      self.messageNotification.lablName.text=[NSString stringWithFormat:@"%@ sent you game invitaion",[userInfo objectForKey:@"user_name"]];
     [App_Delegate.window addSubview:self.messageNotification.view];
    }
 */
    
}




- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

    [application registerForRemoteNotifications];

    [Anagrams_Defaults setObject:@"YES" forKey:isGamePushNotiOn];
    [Anagrams_Defaults synchronize];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [Anagrams_Defaults setObject:@"NO" forKey:isGamePushNotiOn];
    [Anagrams_Defaults synchronize];
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"ACCEPT_IDENTIFIER"])
    {
        [self acceptTheUserRequestHere:userInfo];
    }
    else
    {
 
        
     }
    
    completionHandler();

}








-(void)acceptTheUserRequestHere:(NSDictionary*)dict
{
    
    if (dict) {
        
        [self getPendigGames_Details:dict];
    }
    
    
}



-(void)doXmppDefaultWork
{
    
    if ([[Anagrams_Defaults objectForKey:isLoggedIn]isEqualToString:@"Y"])
    {
       ObjUser *curU=[self loadCustomObjectWithKey:kSavedUser];
        
        self.currentUser.userID          =curU.userID;
        self.currentUser.userAuthKey     =curU.userAuthKey;
        self.currentUser.userEmail       =curU.userEmail;
        self.currentUser.userFBID        =curU.userFBID;
        self.currentUser.userJID         =curU.userJID;
        self.currentUser.userName        =curU.userName;
        self.currentUser.userPassword    =curU.userPassword;
        
    }
    else
    {
        
    }

    self.xmppManager = [XMPPManager sharedManager];
    
}



-(NSString*)getMessageID
{
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyyyyHHmmssSSS"];
    
    NSString *strTimeStamp=[formatter stringFromDate:[NSDate date]];
     NSString *messageID=[NSString stringWithFormat:@"%.0f",[strTimeStamp doubleValue]];
    if (messageID.length<17)
        messageID=[NSString stringWithFormat:@"0%@",messageID];
    
    return messageID;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}



#pragma mark show Invitation pop up

-(void)showInviteVc
{
    
    UINavigationController *top=(UINavigationController*)self.window.rootViewController;
    
     UIViewController *top1=[top topViewController];
    if ([top1 isKindOfClass:[ViewController class]])
    {
        if (self.messageNotification) {
            [self.messageNotification.view removeFromSuperview];
        }
        self.messageNotification=[[AcceptTurnBasedPopUpVC alloc]initWithNibName:@"AcceptTurnBasedPopUpVC" bundle:nil ];
        self.messageNotification.view.frame=CGRectMake(0, 0, App_Delegate.window.frame.size.width, 90);
        [App_Delegate.window addSubview:self.messageNotification.view];

    }
    else
    {
        if (self.InviteVc) {
            
            [self.InviteVc.view removeFromSuperview];
        }
        
        self.InviteVc=[[InvitationPopupVC alloc]init];
        [self.window addSubview:self.InviteVc.view];
        
    }
    
}



- (void)saveCustomObject:(ObjUser *)object key:(NSString *)key
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (ObjUser *)loadCustomObjectWithKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    ObjUser *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}



-(UIViewController*)getGameViewControllerObject:(BOOL)isOnline
{
  //  if (isOnline) {

        if (self.objGameOnline) {
            [self.objGameOnline removeAllObservers];
            self.currentGameId=@"";
        }
        self.objGameOnline=[[ViewController alloc]init];
        return self.objGameOnline;
  //  }
//    else
//    {
//        if (self.objGameOffline) {
//            [self.objGameOffline removeAllObservers];
//            self.currentGameId=@"";
//        }
//        self.objGameOffline=[[OfflineGameVC alloc]init];
//        
//        return self.objGameOffline;
//
//    }
}


-(void)changeRootVieController:(UIViewController*)VC
{
    UINavigationController *nvc=[[UINavigationController alloc]initWithRootViewController:VC];
    self.window.rootViewController=nvc;
    nvc.navigationBarHidden=YES;
    nvc.interactivePopGestureRecognizer.enabled=YES;
    nvc.interactivePopGestureRecognizer.delegate=self;
    [self.window makeKeyAndVisible];

 }


-(BOOL)isXmppConnectedAndAuthenticated
{
    if (App_Delegate.xmppManager.xmppStream.isConnected && App_Delegate.xmppManager.xmppStream.isAuthenticated)
    {
        return YES;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Connection Lost with server"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return NO;
    }
}



//TRY TO CONNECT WITH XMPP IN BG
-(void)tryToConnectWithXmppInBG
{
             if (self.xmppManager.xmppStream.isDisconnected)
            {
                NSString *completeJID = [Anagrams_Defaults objectForKey:kXMPPmyJID];
                if(![App_Delegate.xmppManager connectWithJID:completeJID password:[Anagrams_Defaults objectForKey:kXMPPmyPassword]])
                {
//                    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Server not connected." delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
//                    [alterView show];
                }
                
                //            self.isTryingToReconnectWithXmpp=YES;
            }
 }






- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([[Anagrams_Defaults objectForKey:isLoggedIn]isEqualToString:@"Y"])
    {
        if (!self.xmppManager.xmppStream.isConnecting)
        {
            [self tryToConnectWithXmppInBG];
        }
    }
}


 - (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)showAlertView:(NSString*)strTitle strMessage:(NSString*)strMessage
{

    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:strTitle message:strMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)setValuesInUserDefaults
{
    if (![Anagrams_Defaults integerForKey:kNumberOfCrowns]) {
        [Anagrams_Defaults setInteger:0 forKey:kNumberOfCrowns];
        [Anagrams_Defaults synchronize];
    }
    
    
//    if (![Anagrams_Defaults objectForKey:isTurnBasedGame]) {
//        
//        [Anagrams_Defaults setObject:@"YES" forKey:isTurnBasedGame];
//        [Anagrams_Defaults synchronize];
//    }
    
 
    if (![Anagrams_Defaults objectForKey:isGamePushNotiOn]) {
        
        [Anagrams_Defaults setObject:@"NO" forKey:isGamePushNotiOn];
        [Anagrams_Defaults synchronize];
    }

    if (![Anagrams_Defaults objectForKey:isGameSoundOn]) {
        
        [Anagrams_Defaults setObject:@"YES" forKey:isGameSoundOn];
        [Anagrams_Defaults synchronize];
    }

}


-(void)registerDeviceToken:(NSString*)strToken
{
    
    NSString *strUserId=self.currentUser.userID;
    if (strUserId&&strUserId.length>0) {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setObject:strToken forKey:@"device_token"];
        [dict setObject:@"I" forKey:@"device_type"];
        [dict setObject:strUserId forKey:@"user_id"];
        [dict setObject:@"SANDBOX" forKey:@"environment"];
        [APIsList callPostAsyncAPIUrl:registerDevice withParameter:dict CallBackMethod:@selector(callBackRegisterToken:) toTarget:self showHUD:NO];
    }
}

-(void)callBackRegisterToken:(NSDictionary*)dictRes
{
    if ([[dictRes objectForKey:@"status"]integerValue]==1) {
        
        NSLog(@"Device register %@",dictRes);
    }
}



#pragma mark 
-(void)getPendigGames_Details:(NSDictionary*)info
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (App_Delegate.currentUser.userID)
    {
        [dict setObject:App_Delegate.currentUser.userID forKey:@"user_id"];
        [dict setObject:[info objectForKey:@"game_id"] forKey:@"game_id"];
        [dict setObject:@"user" forKey:@"player_type"];
        
        [APIsList sendJasonDATa:dict url:getOfflineGameDetails Selector:@selector(callBackGetOfflineGameDetails:) WithCallBackObject:self];
    }
    
}

//{"game_id":1157,"user_id":55,"player_type":"user/oponent"}



-(void)callBackGetOfflineGameDetails:(NSDictionary*)dictRes
{
    
    if ([dictRes isKindOfClass:[NSDictionary class]]) {
        
        if ([[dictRes objectForKey:@"status"]integerValue]==1) {
            OfflineGameVC *push=(OfflineGameVC*)[self getGameViewControllerObject:NO];
            push.dictMain=dictRes;
            [self changeRootVieController:push];
        }
        else
        {
            [self showAlertView:@"" strMessage:[dictRes objectForKey:@"message"]];
        }
    }
    
    
}


@end
