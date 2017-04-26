//
//  SignUpVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "SignUpVC.h"
#import "AlreadyPlayedVC.h"
#import "APIsList.h"
#import "UserNameVC.h"
#import "HomeVC.h"
@interface SignUpVC ()

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtEmail.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"E-Mail"
                                                                       attributes:
                                        @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    
    txtPassword.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"Password"
                                                                       attributes:
                                        @{NSForegroundColorAttributeName:[UIColor blackColor]}];

 
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppFailedToConnect) name:kServerLoginFail object:nil];

    // Do any additional setup after loading the view from its nib.
}



-(IBAction)gotoHomeVC
{

    
    
//    HomeVC *hVC=[[HomeVC alloc]init];
//    [self.navigationController pushViewController:hVC animated:YES];
//
//    return;
    
     if (txtEmail.text.length==0||[self isStringIsValidEmail:txtEmail.text])
    {
        [self showAlertMsg:@"Please enter a valid E-Mail"];
        return;

    }
    else if (txtPassword.text.length==0)
    {
        [self showAlertMsg:@"Please enter Password"];
        return;

    }
 
     
    [self signUpMethod];
    
}


-(void)signUpMethod
{
    
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    
    [dict setObject:txtEmail.text forKey:@"email"];
    [dict setObject:txtPassword.text forKey:@"password"];
    
    [APIsList callPostAsyncAPIUrl:signUp withParameter:dict CallBackMethod:@selector(callBackSignUp:) toTarget:self showHUD:YES];
    
    
}


-(void)callBackSignUp:(NSDictionary*)dictRes
{
     if ([dictRes isKindOfClass:[NSDictionary class]] )
    {
        
        if ([[dictRes objectForKey:@"status"]intValue]==1)
        {
            NSDictionary *dictUser=[dictRes objectForKey:@"userdetail"];
            ObjUser *user=[ObjUser currentObject];
            user.userName=[dictUser objectForKey:@"username"];
            user.userID=   [NSString stringWithFormat:@"%@",[dictUser objectForKey:@"id"]];
            user.userEmail=[dictUser objectForKey:@"email"];
            user.userAuthKey=[dictUser objectForKey:@"auth_key"];
            user.userJID=[dictUser objectForKey:@"jid"];
            user.userPassword=txtPassword.text;//[dictUser objectForKey:@"password"];
            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
            [Anagrams_Defaults setObject:txtPassword.text forKey:kXMPPmyPassword];
            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"N" forKey:isSocialLogin];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];
            ObjApp_Delegate.currentUser=user;
            [Anagrams_Defaults synchronize];
            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];
        }
        else
        {
            [self showAlertMsg:[dictRes objectForKey:@"message"]];

        }
        
    }
    else
    {
        [self showAlertMsg:[dictRes objectForKey:@"message"]];
    }
    
}




-(IBAction)btnSignUpWithFBClicked:(id)sender
{
    UserNameVC *hVC=[[UserNameVC alloc]init];
    [self.navigationController pushViewController:hVC animated:YES];
}




-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showAlertMsg:(NSString*)strMsg
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:appname message:strMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}


-(void)xmppConnectedSuccessfully
{
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [self showNotiFicationView];

    
}

-(void)xmppFailedToConnect
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Unable to connect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}



-(void)showNotiFicationView
{
    //Set Animatio
    
    vwPushNotification.hidden=NO;
    vwPushNotification.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    vwPushNotification.alpha=0;
    
    
    [UIView animateWithDuration:0.3  animations:^{
        
        vwPushNotification.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        vwPushNotification.alpha=1;
        [self.view addSubview:vwPushNotification];
    }];
    
}




-(IBAction)removeNotificationView:(UIButton*)sender
{
    
    
    
    
    vwPushNotification.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    vwPushNotification.alpha=1;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        vwPushNotification.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        vwPushNotification.alpha=0;
    }completion:^(BOOL finished) {
        
        [vwPushNotification removeFromSuperview];

        if (sender.tag==100)
        {
          //  [App_Delegate doNotificationsStuffHere];
        }
       [self changeRootToHomevc];
        
    }];
    
}




-(void)changeRootToHomevc
{
    HomeVC *hVC=[[HomeVC alloc]init];
    [ObjApp_Delegate changeRootVieController:hVC];

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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
