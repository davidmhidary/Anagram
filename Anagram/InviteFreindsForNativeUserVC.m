//
//  InviteFreindsForNativeUserVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "InviteFreindsForNativeUserVC.h"
#import "ViewController.h"
@interface InviteFreindsForNativeUserVC ()

@end

@implementation InviteFreindsForNativeUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // NSString *turnBased=[Anagrams_Defaults objectForKey:isTurnBasedGame];
//    if ([turnBased isEqualToString:@"YES"]) {
//         isOnline=NO;
//        }
//    else
//    {
//        isOnline=YES;
//     }
    
    [self getRandomFreinds];

 
}


-(void)viewDidAppear:(BOOL)animated
{
    [Anagrams_NotificationCenter addObserver:self selector:@selector(noMoreInvitationLeft:) name:NodataLeftToSlide object:nil];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(moveBackWhenNoDataIsLeft) name:MoveBackWhenDataBlank object:nil];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationRejected) name:INVITATION_REJECTED object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(nodataLeftAfterSendingInvite) name:Nodataleft_after_AcceptRequest object:nil];
    

}

-(void)viewDidDisappear:(BOOL)animated
{
    [Anagrams_NotificationCenter removeObserver:self name:START_GAME object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:INVITATION_REJECTED object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:MoveBackWhenDataBlank object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:NodataLeftToSlide object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:Nodataleft_after_AcceptRequest object:nil];
}
-(void)moveBackWhenNoDataIsLeft
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)nodataLeftAfterSendingInvite
{
    nodataleft=YES;
}
-(void)createDragableView
{
    draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(0,50,self.view.frame.size.width, self.view.frame.size.height-50)];
     draggableBackground.tag = 301;
    [draggableBackground loadCards];
    [self.view addSubview:draggableBackground];
}


//-(void)noMoreInvitationLeft
//{
//    ViewController *hvc=[[ViewController alloc]init];
//    [self.navigationController pushViewController:hvc animated:YES];
//}



-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
//    if (isOnline) {
        [dictRes setObject:@"online" forKey:@"mode"];
  //  }
//    else
//    {
//        [dictRes setObject:@"offline" forKey:@"mode"];
//    }

    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictRes options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITE_USER Body:myString withID:strMessageID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)getRandomFreinds
{
     NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
     if (App_Delegate.currentUser.userID)
    {
        [dict setObject:[NSString stringWithFormat:@"%@",App_Delegate.currentUser.userID] forKey:@"user_id"];
        [dict setObject:@"N" forKey:@"type"];

        [APIsList callPostAsyncAPIUrl:getFriendsList withParameter:dict CallBackMethod:@selector(callBackFbList:) toTarget:self showHUD:YES];
    }
    
}

-(void)callBackFbList:(NSDictionary*)dictRes
{
    
    if ([dictRes isKindOfClass:[NSDictionary class]])
    {
        if ([[dictRes objectForKey:@"status"]integerValue]==1)
        {
            NSMutableArray *arrf=[dictRes objectForKey:@"user_friend"];
//            NSMutableArray *arrOff=[dictRes objectForKey:@"offline_friend"];

//            if (isOnline)
//            {
                if (arrf.count==0)
                {
                    
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No online friends found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag=123;
                    [alert show];

                }
                else
                {
                    App_Delegate.currentUser.arrFriends=arrf;
                    [self createDragableView];

                }
            
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



#pragma mark start Game Notification

-(void)startTheGameNow:(NSNotification*)notification
{
    NSDictionary *dict=notification.object;
    NSLog(@"Response of Game Start Subject%@",dict);

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss Z";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSString *systDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *startTime=[dict objectForKey:@"starttime"];
    NSDate *date1=[dateFormatter dateFromString:systDate];
    NSDate *date2=[dateFormatter dateFromString:startTime];
    NSTimeInterval dely=[date2 timeIntervalSinceDate:date1];
    
    
    if (dely<10)
    {
        [self performSelector:@selector(GotoGamescreen:) withObject:dict afterDelay:dely];
    }
    else
    {
        [self performSelector:@selector(GotoGamescreen:) withObject:dict afterDelay:5];
    }

    
  
}

-(void)GotoGamescreen:(NSDictionary*)dict
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    App_Delegate.objGameOnline=(ViewController*)[App_Delegate getGameViewControllerObject:YES];
    App_Delegate.objGameOnline.dictMain=dict;
    [App_Delegate changeRootVieController:App_Delegate.objGameOnline];
}

-(void)invitationRejected
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Game Invitation Rejected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag=456;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==123) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else if (alertView.tag==456)
    {
        if (nodataleft) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}


@end
