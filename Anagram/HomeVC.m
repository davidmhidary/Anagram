//
//  HomeVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "HomeVC.h"
#import "SettingsVC.h"
#import "LeaderBoardVC.h"
#import "PurchageCrownsVC.h"
#import "ViewController.h"
#import "WordOfTheDayVC.h"
#import "InstructionsVC.h"
#import "MyProfileVC.h"
#import "RateVC.h"
#import "InviteFreindsForNativeUserVC.h"
#import "PlayerTypeVC.h"
#import "WinsAndLosesVC.h"
#import "OfflineGameVC.h"
#import "FriendsListVC.h"
#import "PendingRequestsVC.h"
#import "ContactListVC.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {

   [super viewDidLoad];
   app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
  [self getWordOfTheDay];
   app.currentGameId=@"";
    
    if ([Anagrams_Defaults objectForKey:FBID]) {
        lblFBConnected.text=@"Connected";
    }
    else
    {
        lblFBConnected.text=@"Not Connected";
    }

   // [self checkIfRegisteredForPushNotification];
    
    [ObjApp_Delegate doNotificationsStuffHere];
    [self registerDeviceToken:ObjApp_Delegate.strToken];
    
    // Do any additional setup after loading the view from its nib.
    
    
//    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
//    
//    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
//    lbl.textAlignment=NSTextAlignmentRight;
//    lbl.textColor=[UIColor whiteColor];
//    lbl.text=build;
//    [ObjApp_Delegate.window addSubview:lbl];
    


}


-(void)viewDidAppear:(BOOL)animated
{
 
    lblWelcomeUser.text=[NSString stringWithFormat:@"Welcome %@!",ObjApp_Delegate.currentUser.userName];
    
    scrl.contentSize=CGSizeMake(self.view.frame.size.width, 568);

}

-(IBAction)btnSettingsClicked:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];
     SettingsVC *SVC=[[SettingsVC alloc]init];
    [self.navigationController pushViewController:SVC animated:YES];
 }

-(IBAction)btnLeaderBoardClicked:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];

    LeaderBoardVC *SVC=[[LeaderBoardVC alloc]init];
    [self.navigationController pushViewController:SVC animated:YES];
}

-(IBAction)btnWODClicked:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];

    WordOfTheDayVC *SVC=[[WordOfTheDayVC alloc]init];
    SVC.strWordOfDay=strWordOfDay;
    [self.navigationController pushViewController:SVC animated:YES];
}

-(IBAction)btnInstructionsClicked:(id)sender
{
    InstructionsVC *SVC=[[InstructionsVC alloc]init];
    SVC.isLiveVersion=btnSwithLiveTurn.selected;
    [self.navigationController pushViewController:SVC animated:YES];
}

-(IBAction)btnPlayLiveTurnsClicked:(UIButton*)sender
{

    
    [self playGameSounds:@"STACK_TAP"];

    PlayerTypeVC *P=[[PlayerTypeVC alloc]init];
    [self.navigationController pushViewController:P animated:YES];
 }

-(IBAction)btnMyProfilePressed:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];

    MyProfileVC *mvC=[[MyProfileVC alloc]init];
    [self.navigationController pushViewController:mvC animated:YES];
}


-(IBAction)btnRateUs:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];

    RateVC *rVc=[[RateVC alloc]init];
    [self.navigationController pushViewController:rVc animated:YES];
    
}


-(IBAction)btnWinsAndLossesPress:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];

    WinsAndLosesVC*winV=[[WinsAndLosesVC alloc]init];
    [self.navigationController pushViewController:winV animated:YES];
}

-(IBAction)btnAddFreindClicked:(id)sender
{
//    FriendsListVC*winV=[[FriendsListVC alloc]init];
//    winV.shouldHidePendigReqbtn=YES;
//    winV.isOnline=btnSwithLiveTurn.selected;
//    [self.navigationController pushViewController:winV animated:YES];
    
    [self playGameSounds:@"STACK_TAP"];

    ContactListVC *Cvc=[[ContactListVC alloc]init];
    [self.navigationController pushViewController:Cvc animated:YES];

}

-(IBAction)btnPlusClicked:(id)sender
{
    
    [self playGameSounds:@"STACK_TAP"];

    FriendsListVC*winV=[[FriendsListVC alloc]init];
    winV.shouldHidePendigReqbtn=NO;
    winV.isOnline=btnSwithLiveTurn.selected;

    [self.navigationController pushViewController:winV animated:YES];
    
}



-(IBAction)btnInboxClicked:(id)sender
{
    [self playGameSounds:@"STACK_TAP"];
     PendingRequestsVC *Vc=[[PendingRequestsVC alloc]init];
    [self.navigationController presentViewController:Vc animated:YES completion:nil];
}
-(void)getWordOfTheDay
{

    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    NSDateFormatter *dFormat=[[NSDateFormatter alloc]init];
    [dFormat setDateFormat:@"yyyy-MM-dd"];
//  [dFormat setDateFormat:@"2016-06-28"];
   
    
    NSString *strDAte=[dFormat stringFromDate:[NSDate date]];
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:strDAte forKey:@"date"];
    
    [APIsList sendJasonDATa:dict url:WordofTheDay Selector:@selector(callBackWordOfDay:) WithCallBackObject:self];
    
}


-(void)callBackWordOfDay:(NSDictionary*)dictRes
{
    NSLog(@"WordOf the Day Response %@",dictRes);
    if ([[dictRes objectForKey:@"status"]integerValue]==1)
    {
        strWordOfDay=[dictRes objectForKey:@"word"];
    }
    if (strWordOfDay.length>0)
    {
        lblWordOfDay.text=strWordOfDay;
         NSInteger point=(strWordOfDay.length-2)*2;
        lblNumberOfPoints.text=[NSString stringWithFormat:@"%ld Points",(long)point];
    }
}


-(IBAction)btnTurnSwitchPressed:(UIButton*)sender
{
    
//    NSString *strTurnBased=@"NO";
//    
//    if (sender.selected) {
//        sender.selected=NO;
//        lblTurnLive.text=@"Play Turn";
//         strTurnBased=@"YES";
//    }
//    else
//    {
//        sender.selected=YES;
//        lblTurnLive.text=@"Play Live";
//        strTurnBased=@"NO";
//    }
//    
//    [Anagrams_Defaults setObject:strTurnBased forKey:isTurnBasedGame];
//    [Anagrams_Defaults synchronize];
}


#pragma mark Connect To facebook

-(IBAction)loginWithFacebook
{
    [self playGameSounds:@"STACK_TAP"];

    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    login.loginBehavior=FBSDKLoginBehaviorWeb;
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self fetchUserInfo];
    }
    else
    {
        [login
         logInWithReadPermissions: @[@"public_profile",@"email", @"user_friends"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Process error");
             } else if (result.isCancelled)
             {
                 NSLog(@"Cancelled");
             } else {
                 
                 NSLog(@"Logged in");
                 
                 [self fetchUserInfo];
             }
         }];
        
    }
    
}



-(void)fetchUserInfo
{
    NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, last_name, picture.type(large), email, birthday, bio ,location ,friends ,hometown , friendlists"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error)
         {
             NSLog(@"resultis:%@",result);
             
             [self processUserInfo:result];
         }
         else
         {
             NSLog(@"Error %@",error);
         }
     }];
    
    
}


-(void)processUserInfo:(NSMutableDictionary*)dictInfo
{
    NSString *strUserFBID=[dictInfo objectForKey:@"id"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getFriendListofUser:strUserFBID];
}





-(void)getFriendListofUser:(NSString*)fbId
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters:@{@"fields": @"id,name,picture.width(300)"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error)
     {
         
         if (error)
         {
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         }
         else
         {
              NSDictionary *dict=result;
              [self saveFbFriendsOnServer:[dict objectForKey:@"data"]fbId:fbId];
         }
     }];
    
}



-(void)saveFbFriendsOnServer:(NSArray*)arr fbId:(NSString*)f_id
{
    

    [Anagrams_Defaults setObject:f_id forKey:FBID];
    [Anagrams_Defaults synchronize];
    
    lblFBConnected.text=@"Connected";
    
    ObjUser *currentU=[ObjUser currentObject];
    
    NSMutableArray *arrFreinds=[[NSMutableArray alloc]init];
    
    
    for (int i=0; i<arr.count; i++) {
        NSDictionary *dict=[arr objectAtIndex:i];
        NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
        [dictF setObject:[dict objectForKey:@"id"] forKey:@"social_id"];
        [dictF setObject:[dict objectForKey:@"name"] forKey:@"username"];
        [dictF setObject:@"no image" forKey:@"profile_image"];
        [arrFreinds addObject:dictF];
    }

    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:arrFreinds options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    [dict setObject:f_id forKey:@"social_id"];
    [dict setObject:currentU.userID forKey:@"user_id"];
    [dict setObject:myString forKey:@"frd_data"];
    [APIsList callPostAsyncAPIUrl:SaveFBFriends withParameter:dict CallBackMethod:@selector(callBackSaveFBFriends:) toTarget:self showHUD:NO];
}


-(void)callBackSaveFBFriends:(NSDictionary*)dict
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    NSLog(@"response Save Fb Friends %@",dict);
    
    if ([[dict objectForKey:@"status"]integerValue]==1)
    {
 
    }
    else if([dict objectForKey:@"message"])
    {
//
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    
}




#pragma mark Play Game Sounds

-(void)playGameSounds:(NSString*)type
{
    
    NSString *soundOn  =[Anagrams_Defaults objectForKey:isGameSoundOn];
    if ([soundOn isEqualToString:@"YES"]) {
        
        NSString *strFileName=@"";
        
        if ([type isEqualToString:@"STACK_TAP"]) {
            
            strFileName=@"Sounds/Stack_tap";
        }
         
        NSString *path = [[NSBundle mainBundle]pathForResource:strFileName ofType:@"wav"];
        
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        player.numberOfLoops=0;
        [player prepareToPlay];
        player.volume=1.0;
        [player play];
        
        
    }
    else
    {
        // don't play sound when it is off in setting;
    }
    
}



-(void)registerDeviceToken:(NSString*)strToken
{
    
    NSString *strUserId=ObjApp_Delegate.currentUser.userID;
    
    if (strUserId&&strUserId.length>0) {
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        if (strToken) {
            [dict setObject:strToken forKey:@"device_token"];
        }
        else
        {
            [dict setObject:@"User not allowed the notification" forKey:@"device_token"];
        }
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


-(void)checkIfRegisteredForPushNotification
{
   BOOL check=    [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];

    if (check) {
        
    }
    else
    {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push notifications not enabled"
                                                            message:@"You need to enable your push notifcation!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];

        alertView.tag=5001;
        [alertView show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==5001) {
        
        if (buttonIndex==1) {
            NSURL* settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
