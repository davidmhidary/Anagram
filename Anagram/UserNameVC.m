//
//  UserNameVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "UserNameVC.h"
#import "AlreadyPlayedVC.h"
#import "APIsList.h"
#import "HomeVC.h"
#import "NSString+MD5ofString.h"
@interface UserNameVC ()

@end

@implementation UserNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    txtUserName.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"Username"
                                                                    attributes:
                                     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppFailedToConnect) name:kServerLoginFail object:nil];

    // Do any additional setup after loading the view from its nib.
}


-(IBAction)doneClicked:(id)sender
{
    
//    HomeVC *hVC=[[HomeVC alloc]init];
//    [self.navigationController pushViewController:hVC animated:YES];
 //   return;
    
    if (txtUserName.text.length==0)
    {
    
        [[[UIAlertView alloc]initWithTitle:appname message:@"Please enter username first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
        
        return;
    }
    
    [self callSignupApi];
}


-(void)callSignupApi
{
    
    NSString *strEmail=[self.dictInfo objectForKey:@"email"];
   // NSString *strFName=[self.dictInfo objectForKey:@"first_name"];
    NSString *strFBID=[self.dictInfo objectForKey:@"id"];
    
    ObjApp_Delegate.currentUser.userFBID=strFBID;
 
    NSMutableDictionary *dictParmas=[[NSMutableDictionary alloc]init];
    
    
    [dictParmas setObject:strEmail forKey:@"email"];
    [dictParmas setObject:txtUserName.text forKey:@"username"];
    [dictParmas setObject:strFBID forKey:@"social_id"];
   // [dictParmas setObject:strFName forKey:@"first_name"];
    
    
   // [APIsList callPostAsyncAPIUrl:signInSocial withParameter:dictParmas CallBackMethod:@selector(callSocialLogin:) toTarget:self showHUD:YES];
    
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
            
            
            [Anagrams_Defaults setObject:user.userJID forKey:kXMPPmyJID];
            [Anagrams_Defaults setObject:[[NSString stringWithFormat:@"%@",user.userID] MD5String] forKey:kXMPPmyPassword];
            
            [Anagrams_Defaults setObject:@"Y" forKey:isLoggedIn];
            [Anagrams_Defaults setObject:@"Y" forKey:isSocialLogin];
            

            [[XMPPManager sharedManager] performSelectorOnMainThread:@selector(connectToServer) withObject:nil waitUntilDone:NO];

            [Anagrams_Defaults synchronize];
            
            [ObjApp_Delegate saveCustomObject:user key:kSavedUser];

            
 

        }
            
    }
    
}


/*
 username
 email
 password
 first_name
 last_name
 */


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "])
    {
        return NO;
    }
    
    return YES;
}

-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
