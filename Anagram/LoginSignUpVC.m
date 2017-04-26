//
//  LoginSignUpVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "LoginSignUpVC.h"
#import "LoginVC.h"
#import "SignUpVC.h"
#import "UserNameVC.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "HomeVC.h"
#import "NSString+MD5ofString.h"

@interface LoginSignUpVC ()

@end

@implementation LoginSignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtEmail.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"Email"
                                                                    attributes:
                                     @{NSForegroundColorAttributeName:[UIColor blackColor]}];

    // Do any additional setup after loading the view from its nib.

    
    
}

-(void)viewDidAppear:(BOOL)animated

{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppFailedToConnect) name:kServerLoginFail object:nil];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [Anagrams_NotificationCenter removeObserver:self name:kServerLoginSuccess object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:kServerLoginFail object:nil];
}

-(IBAction)btnFBLoginClicked:(id)sender
{
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    app.isLoginWithFaceBook=YES;
    
    
//    HomeVC *hVC=[[HomeVC alloc]init];
//    [self.navigationController pushViewController:hVC animated:YES];
////
//   return;
    
    [self loginWithFacebook];
}
-(IBAction)btnLoginClicked:(id)sender
{
    LoginVC *loginVC=[[LoginVC alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
-(IBAction)btnSignUpClicked:(id)sender
{
 
     SignUpVC *loginVC=[[SignUpVC alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}



-(BOOL) isStringIsValidEmail:(NSString *)email
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return ![emailTest evaluateWithObject:email];
}




-(void)loginWithFacebook
{

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
    
    
  
    dictFBUserInfo=dictInfo;
    
    [self checkIfUserAlreadyExist:[dictInfo objectForKey:@"email"]];
    
}




-(void)checkIfUserAlreadyExist:(NSString*)emailUser
{
    NSString *strFBID=[dictFBUserInfo objectForKey:@"id"];


    
    NSMutableDictionary *dictParmas=[[NSMutableDictionary alloc]init];
//   [dict setObject:emailUser forKey:@"email"];
//   [APIsList callPostAsyncAPIUrl:checkUser withParameter:dict CallBackMethod:@selector(callBackCheckIfUserExists:) toTarget:self showHUD:YES];
    
    
    [dictParmas setObject:emailUser forKey:@"email"];
     [dictParmas setObject:strFBID forKey:@"social_id"];
    
    [APIsList callPostAsyncAPIUrl:signInSocial withParameter:dictParmas CallBackMethod:@selector(callBackCheckIfUserExists:) toTarget:self showHUD:YES];

}


-(void)callBackCheckIfUserExists:(NSDictionary*)dictRes
{

        NSLog(@"Response %@",dictRes);
    if ([dictRes isKindOfClass:[NSDictionary class]])
    {
        if ([[dictRes objectForKey:@"status"] isEqualToString:@"1"])
        {

            NSDictionary *dictUser=[dictRes objectForKey:@"userdetail"];
            ObjUser *user=[ObjUser currentObject];
            
            user.userName=[dictUser objectForKey:@"username"];
            user.userID=[NSString stringWithFormat:@"%@",[dictUser objectForKey:@"id"]];
            user.userEmail=[dictUser objectForKey:@"email"];
            user.userAuthKey=[dictUser objectForKey:@"auth_key"];
            
            user.userJID=[NSString stringWithFormat:@"%@",[dictUser objectForKey:@"jid"]];
            user.userPassword=[dictUser objectForKey:@"password"];

            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
            [Anagrams_Defaults setObject:[[NSString stringWithFormat:@"%@",user.userID] MD5String] forKey:kXMPPmyPassword];
            
            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"Y" forKey:isSocialLogin];

            
            [Anagrams_Defaults synchronize];
            
            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self getFriendListofUser:[dictFBUserInfo objectForKey:@"id"]];
            
 
            user.userFBID=[dictFBUserInfo objectForKey:@"id"];
            ObjApp_Delegate.currentUser.userFBID=[dictFBUserInfo objectForKey:@"id"];
            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];
            ObjApp_Delegate.currentUser=user;

            
        }
        else if([[dictRes objectForKey:@"status"] isEqualToString:@"404"])
        {
//            UserNameVC *hVC=[[UserNameVC alloc]init];
//            hVC.dictInfo =dictFBUserInfo;
//            [self.navigationController pushViewController:hVC animated:YES];

        }
        else
        {
            UIAlertView *alertview=[[UIAlertView alloc]initWithTitle:@"" message:[dictRes objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertview show];

        }
        
    }
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
             
         }
         else
         {
           //  NSLog(@"USERS %@",result);
             

             NSDictionary *dict=result;
             
            [self saveFbFriendsOnServer:[dict objectForKey:@"data"]fbid:fbId];
         }
      }];
    
}



-(void)saveFbFriendsOnServer:(NSArray*)arr fbid:(NSString*)fb_id
{
    
    [Anagrams_Defaults setObject:fb_id forKey:FBID];
    [Anagrams_Defaults synchronize];

    
    
    ObjUser *currentU=[ObjUser currentObject];
    
    // user_id
//    frd_data
    //[{"username":"d","profile_image":"profile","social_id":"131346"},{"username":"df","profile_image":"df","social_id":"dfd"}]
    
    NSMutableArray *arrFreinds=[[NSMutableArray alloc]init];
    
//    NSString *fbFriends=@"";
    
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
    
    [dict setObject:currentU.userID forKey:@"user_id"];
    [dict setObject:fb_id forKey:@"social_id"];

    [dict setObject:myString forKey:@"frd_data"];
    
    [APIsList callPostAsyncAPIUrl:SaveFBFriends withParameter:dict CallBackMethod:@selector(callBackSaveFBFriends:) toTarget:self showHUD:NO];
    
}


-(void)callBackSaveFBFriends:(NSDictionary*)dict
{
    
    NSLog(@"response Save Fb Friends %@",dict);
}

 

-(void)xmppConnectedSuccessfully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    HomeVC *hVC=[[HomeVC alloc]init];
    [ObjApp_Delegate changeRootVieController:hVC];
    
    //  [self.navigationController pushViewController:hVC animated:YES];
    
}

-(void)xmppFailedToConnect
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Unable to connect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
