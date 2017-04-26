//
//  PlayerTypeVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "PlayerTypeVC.h"
#import "FriendsListVC.h"
#import "InviteFreindsForNativeUserVC.h"
@interface PlayerTypeVC ()

@end

@implementation PlayerTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
 
    if (app.isLoginWithFaceBook) {
        
        viewFbLogin.hidden=NO;
        viewNAtiveLogin.hidden=YES;
    }
    else
    {
        viewFbLogin.hidden=YES;
        viewNAtiveLogin.hidden=NO;
        
 

    }
    
    
    
    // Do any additional setup after loading the view from its nib.
}


-(void)viewDidAppear:(BOOL)animated
{
    if (app.isLoginWithFaceBook) {
    }
    else
    {
//        [Anagrams_NotificationCenter addObserver:self selector:@selector(noMoreInvitationLeft:) name:NodataLeftToSlide object:nil];
//        [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];
//        [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationRejected) name:INVITATION_REJECTED object:nil];
     }

}

-(void)viewDidDisappear:(BOOL)animated
{
//    [Anagrams_NotificationCenter removeObserver:self name:START_GAME object:nil];
//    [Anagrams_NotificationCenter removeObserver:self name:INVITATION_REJECTED object:nil];
//    [Anagrams_NotificationCenter removeObserver:self name:MoveBackWhenDataBlank object:nil];
//    [Anagrams_NotificationCenter removeObserver:self name:NodataLeftToSlide object:nil];
    
    
}



-(IBAction)btnFriendClicked:(id)sender
{

    
    FriendsListVC *fVC=[[FriendsListVC alloc]init];
    [self.navigationController pushViewController:fVC animated:YES];
    
}


-(IBAction)btnRandomClicked:(id)sender
{
    InviteFreindsForNativeUserVC *hVC=[[InviteFreindsForNativeUserVC alloc]init];
    [self.navigationController pushViewController:hVC animated:YES];

}

-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}





#pragma mark Login to play with Facebook



-(IBAction)loginWithFacebook
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
             //  NSLog(@"USERS %@",result);
             
             
             NSDictionary *dict=result;
             
             [self saveFbFriendsOnServer:[dict objectForKey:@"data"]fbId:fbId];
         }
     }];
    
}



-(void)saveFbFriendsOnServer:(NSArray*)arr fbId:(NSString*)f_id
{
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
    NSLog(@"response Save Fb Friends %@",dict);
    
    if ([[dict objectForKey:@"status"]integerValue]==1)
    {
        [self getFbFriends];
 
    }
    else if([dict objectForKey:@"message"])
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
    }

}


-(void)getFbFriends
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (App_Delegate.currentUser.userID)
    {
        [dict setObject:[NSString stringWithFormat:@"%@",App_Delegate.currentUser.userID] forKey:@"user_id"];
        [dict setObject:@"S" forKey:@"type"];
        [APIsList callPostAsyncAPIUrl:getFriendsList withParameter:dict CallBackMethod:@selector(callBackFbList:) toTarget:self showHUD:YES];
    }
    
}

-(void)callBackFbList:(NSDictionary*)dictRes
{
    
    if ([dictRes isKindOfClass:[NSDictionary class]])
    {
        if ([[dictRes objectForKey:@"status"]integerValue]==1)
        {
            NSMutableArray *arrf=[dictRes objectForKey:@"offline_friend"];
            App_Delegate.currentUser.arrFriends=arrf;
            [self createDragableView];
        }
        else if([dictRes objectForKey:@"message"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[dictRes objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=123;
            [alert show];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No online friends found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=123;
            [alert show];
            
        }
        
    }
}



-(void)createDragableView
{
    
    //  draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(10,80, 301, 430)];
    draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    draggableBackground.tag = 301;
    [draggableBackground loadCards];
    [self.view addSubview:draggableBackground];
}




-(void)noMoreInvitationLeft:(NSNotification*)notification
{
    
    NSMutableDictionary *dict=notification.object;
    
    NSMutableDictionary *dictRes=[[NSMutableDictionary alloc]init];
    [dictRes setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dictRes setObject:[dict objectForKey:@"id"] forKey:@"opponent_id"];
    if (App_Delegate.isLoginWithFaceBook)
    {
        [dictRes setObject:@"FB" forKey:@"player_type"];
    }
    else
    {
        [dictRes setObject:@"NATIVE" forKey:@"player_type"];
    }
    [dictRes setObject:[dict objectForKey:@"username"] forKey:@"user_name"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictRes options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITE_USER Body:myString withID:strMessageID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)startTheGameNow:(NSNotification*)notification
{
    NSDictionary *dict=notification.object;
    NSLog(@"Response of Game Start Subject%@",dict);
//    App_Delegate.objGameVC=[App_Delegate getGameViewControllerObject];
//    App_Delegate.objGameVC.dictMain=dict;
//    [App_Delegate changeRootVieController:App_Delegate.objGameVC];
    
    //    [self.navigationController pushViewController:homeVC animated:YES];
}


-(void)invitationRejected
{
    
    [draggableBackground removeFromSuperview];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Game Invitation Rejected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
