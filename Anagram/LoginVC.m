//
//  LoginVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "LoginVC.h"
#import "HomeVC.h"
#import "AlreadyPlayedVC.h"
#import "UserNameVC.h"
#import "APIsList.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    Avenir-Heavy
    
    
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    txtEmail.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"E-Mail"
                                                                         attributes:
                                          @{NSForegroundColorAttributeName:[UIColor blackColor],}];
    
    
    txtPassword.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"Password"
                                                                    attributes:
                                     @{NSForegroundColorAttributeName:[UIColor blackColor]}];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppFailedToConnect) name:kServerLoginFail object:nil];

    // Do any additional setup after loading the view from its nib.
}



-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     return YES;
}



-(IBAction)gotoHomeVC
{
    
 
    
    
    app.isLoginWithFaceBook=NO;

//    HomeVC *hVC=[[HomeVC alloc]init];
//    [self.navigationController pushViewController:hVC animated:YES];
//
//
//    return;
//    
  
    if (txtEmail.text.length==0) {
        
        [[[UIAlertView alloc]initWithTitle:appname message:@"Please enter email/ Username" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
        return;
    }
//    else if ([self isStringIsValidEmail:[txtEmail text]])
//    {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please enter valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
     else if (txtPassword.text.length==0)
    {
        [[[UIAlertView alloc]initWithTitle:appname message:@"Please enter Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
        return;
    }
    
    [self.view endEditing:YES];

    [self login];
}


-(void)login
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    
    [dict setObject:txtEmail.text forKey:@"email"];
    [dict setObject:txtPassword.text forKey:@"password"];
    [APIsList callPostAsyncAPIUrl:signIn withParameter:dict CallBackMethod:@selector(callBackLogin:) toTarget:self showHUD:YES];
    
    
}


-(void)callBackLogin:(NSDictionary*)dictRes
{
    if ([dictRes isKindOfClass:[NSDictionary class]] )
    {
    
        if ([[dictRes objectForKey:@"status"]intValue]==1)
        {
            
            NSDictionary *dictUser=[dictRes objectForKey:@"userdetail"];
            
            ObjUser *user=[ObjUser currentObject];
            
            user.userName=[dictUser objectForKey:@"username"];
            user.userLName=[dictUser objectForKey:@"last_name"];
            user.userID=[NSString stringWithFormat:@"%@",[dictUser objectForKey:@"id"]];
            user.userFName=[dictUser objectForKey:@"first_name"];
            user.userEmail=[dictUser objectForKey:@"email"];
            user.userAuthKey=[dictUser objectForKey:@"auth_key"];
            
            user.userJID=[dictUser objectForKey:@"jid"];
            user.userPassword=  txtPassword.text;        // [dictUser objectForKey:@"password"];
            
            
            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
            [Anagrams_Defaults setObject:txtPassword.text forKey:kXMPPmyPassword];
            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];

            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"N" forKey:isSocialLogin];
            

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [Anagrams_Defaults synchronize];
            
            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];

            ObjApp_Delegate.currentUser=user;
            
        //    [App_Delegate doNotificationsStuffHere];


        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:appname message:[dictRes objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];

        }
        
    }
    else
    {
        
    }
    
}



//

-(IBAction)btnForgotPasswordClicked:(id)sender
{
    
    UIAlertView * forgotPassword=[[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Please enter your email id" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    forgotPassword.tag = 1;
    forgotPassword.alertViewStyle=UIAlertViewStylePlainTextInput;
    
    [forgotPassword show];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1)
    {
        NSString *femailId=[alertView textFieldAtIndex:0].text;
        
        
        if (femailId.length==0||[self isStringIsValidEmail:femailId])
        {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];

        }
        else
        {
            [self callForgotPasswordApi:femailId];
        }

    }
}





-(void)callForgotPasswordApi:(NSString*)email
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:email forKey:@"email"];
    [APIsList callPostAsyncAPIUrl:forgotPasswordApi withParameter:dict CallBackMethod:@selector(callBackForgotPassword:) toTarget:self showHUD:YES];

    
}

-(void)callBackForgotPassword:(NSDictionary*)dictRes
{

    if ([dictRes isKindOfClass:[NSDictionary class]])
    {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictRes objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];

    }

}





-(void)loginButtonClicked
{
    
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
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
    
    
    [self getFriendListofUser:[dictInfo objectForKey:@"id"]];
    app.isLoginWithFaceBook=YES;
    UserNameVC *hVC=[[UserNameVC alloc]init];
    hVC.dictInfo=dictInfo;
 //   [self.navigationController pushViewController:hVC animated:YES];
    
    
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
            
        }
        // Handle the result
    }];

}


-(IBAction)btnFBLoginClicked:(id)sender
{
    app.isLoginWithFaceBook=YES;
    UserNameVC *hVC=[[UserNameVC alloc]init];
//    hVC.dictInfo=dictInfo;
   [self.navigationController pushViewController:hVC animated:YES];

    return
    [self loginButtonClicked ];
    
    
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
