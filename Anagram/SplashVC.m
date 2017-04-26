//
//  SplashVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 21/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "SplashVC.h"
#import "BeginVC.h"
#import "AppDelegate.h"
#import "HomeVC.h"
#import "LoginSignUpVC.h"
#import "NSString+MD5ofString.h"
@interface SplashVC ()

@end

@implementation SplashVC


-(void)viewDidAppear:(BOOL)animated
{
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if ([[Anagrams_Defaults objectForKey:isLoggedIn]isEqualToString:@"Y"])
    {
        indicator.hidden=NO;

        if ([[Anagrams_Defaults objectForKey:isSocialLogin] isEqualToString:@"Y"]) {
            
            [self callSocialSignIn];
        }
        else
        {
            [self login];
        }
        // call Native login or FB Login API
    }
    else
    {
        indicator.hidden=YES;
      [self performSelector:@selector(changeRootAfterDelay) withObject:nil afterDelay:2.0];
      
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppFailedToConnect) name:kServerLoginFail object:nil];

    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    CGRect frame=[[UIScreen mainScreen]bounds];
    
    
    if (frame.size.height<500)
    {
        imgBG.image=[UIImage imageNamed:@"Default"];
    }
    else if (frame.size.height<600)
    {
        imgBG.image=[UIImage imageNamed:@"Default-568h"];

    }
    else if (frame.size.height<700)
    {
        imgBG.image=[UIImage imageNamed:@"Default-667h"];

    }
    else
    {
        imgBG.image=[UIImage imageNamed:@"Default-736h"];

    }

    // Do any additional setup after loading the view from its nib.
}














-(void)login
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
     
    [dict setObject:ObjApp_Delegate.currentUser.userEmail forKey:@"email"];
    [dict setObject:ObjApp_Delegate.currentUser.userPassword forKey:@"password"];
    [APIsList callPostAsyncAPIUrl:signIn withParameter:dict CallBackMethod:@selector(callBackLogin:) toTarget:self showHUD:NO];
    
    
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
            user.userID=[dictUser objectForKey:@"id"];
            user.userFName=[dictUser objectForKey:@"first_name"];
            user.userEmail=[dictUser objectForKey:@"email"];
            user.userAuthKey=[dictUser objectForKey:@"auth_key"];
            
            user.userJID=[dictUser objectForKey:@"jid"];
//            user.userPassword=[dictUser objectForKey:@"password"];
            
            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"N" forKey:isSocialLogin];

            
            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
//            [Anagrams_Defaults setObject:txtPassword.text forKey:kXMPPmyPassword];
            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];
            
            
    //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];

            [Anagrams_Defaults synchronize];
            
            ObjApp_Delegate.isLoginWithFaceBook=NO;

        }
        else
        {
                 [self changeRootAfterDelay];
 
        }
        
    }
    else
    {
        
    }
    
}






-(void)callSocialSignIn
{
    
     NSMutableDictionary *dictParmas=[[NSMutableDictionary alloc]init];
    
    
    [dictParmas setObject:ObjApp_Delegate.currentUser.userEmail forKey:@"email"];
    [dictParmas setObject:ObjApp_Delegate.currentUser.userName forKey:@"username"];
    [dictParmas setObject:ObjApp_Delegate.currentUser.userFBID forKey:@"social_id"];
    // [dictParmas setObject:strFName forKey:@"first_name"];
    
    
    [APIsList callPostAsyncAPIUrl:signInSocial withParameter:dictParmas CallBackMethod:@selector(callSocialLogin:) toTarget:self showHUD:NO];
    
}

-(void)callSocialLogin:(NSDictionary*)dict
{
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        
        if([[dict objectForKey:@"status"]intValue]==1)
        {
            
            
            NSDictionary *dictUser=[dict objectForKey:@"userdetail"];
            ObjUser *user=[ObjUser currentObject];
            
            user.userName=[dictUser objectForKey:@"username"];
            user.userLName=[dictUser objectForKey:@"last_name"];
            user.userID=[dictUser objectForKey:@"id"];
            user.userFName=[dictUser objectForKey:@"first_name"];
            user.userEmail=[dictUser objectForKey:@"email"];
            user.userAuthKey=[dictUser objectForKey:@"auth_key"];
            
            user.userJID=[dictUser objectForKey:@"jid"];
            user.userPassword=[dictUser objectForKey:@"password"];
            
            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"Y" forKey:isSocialLogin];

            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
            [Anagrams_Defaults setObject:[user.userID MD5String] forKey:kXMPPmyPassword];
            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];

            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];

            [Anagrams_Defaults synchronize];
            
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            
            ObjApp_Delegate.isLoginWithFaceBook=YES;

            
        }
       else
       {
      
           [self changeRootAfterDelay];
       }
    }
    
}






-(void)changeRootAfterDelay
{
    LoginSignUpVC *vc=[[LoginSignUpVC alloc]init];
    [ObjApp_Delegate changeRootVieController:vc];
}


-(void)gotoHomeVCifLoggedIn
{
    HomeVC *vc=[[HomeVC alloc]init];
    [ObjApp_Delegate changeRootVieController:vc];
}

-(void)xmppConnectedSuccessfully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    indicator.hidden=YES;

    [self gotoHomeVCifLoggedIn];
}

-(void)xmppFailedToConnect
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    indicator.hidden=YES;

    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Unable to connect" delegate:self cancelButtonTitle:@"RETRY" otherButtonTitles:@"Cancel", nil];
    
    alert.tag=123;
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==123)
    {
        if (buttonIndex==0)
        {

//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            indicator.hidden=NO;

            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];

        }
        else
        {
            [self changeRootAfterDelay];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 
@end
