//
//  FriendsListVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "FriendsListVC.h"
#import "InviteFriendCell.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "OfflineGameVC.h"
#import "PendingRequestsVC.h"
#import "ContactListVC.h"
#import "SVPullToRefresh.h"
@interface FriendsListVC ()

@end

@implementation FriendsListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [self getFbFriends];
    
    
    if ([tblView respondsToSelector:@selector(setSectionIndexColor:)])
    {
        tblView.sectionIndexColor =           [UIColor whiteColor];
        tblView.sectionIndexBackgroundColor = [UIColor clearColor];
    }

    if (self.shouldHidePendigReqbtn) {
        
        btnPendingRequests.hidden=YES;
    }
    else
    {
        btnPendingRequests.hidden=YES;
    }
    
    
        __weak FriendsListVC *weakSelf = self;
    
        [tblView addPullToRefreshWithActionHandler:^{
            [weakSelf getFbFriends];
        }];
    


    
}

-(void)viewDidAppear:(BOOL)animated
{
 //   [self createDragableView];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(noMoreInvitationLeft:) name:NodataLeftToSlide object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationRejected) name:INVITATION_REJECTED object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(moveBackWhenNoDataIsLeft) name:MoveBackWhenDataBlank object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(nodataLeftAfterSendingInvite) name:Nodataleft_after_AcceptRequest object:nil];

    
    [self.view.window setBackgroundColor:[UIColor redColor]];

    [Anagrams_NotificationCenter addObserver:self selector:@selector(sentNotificationToComeOnline:) name:INVITE_SEND_NOTIFICATION object:nil];

    
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return arrFreinds.count;
}


//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    
// return[NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
//    
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    if (thisTableDataIsShowing)
//    {
        NSMutableArray *charactersForSort = [[NSMutableArray alloc] init];
        for (NSDictionary *item in arrFreinds)
        {
            NSString*strKey=[[[item valueForKey:@"username"] substringToIndex:1] uppercaseString];
            if (![charactersForSort containsObject:strKey])
            {
                [charactersForSort addObject:strKey];
            }
        }
        return charactersForSort;
//    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    BOOL found = NO;
    NSInteger b = 0;
    for (NSDictionary *item in arrFreinds)
    {
        NSString*strKey=[[[item valueForKey:@"username"] substringToIndex:1] uppercaseString];
        if ([strKey isEqualToString:title])
            if (!found)
            {
                [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:b inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                found = YES;
            }
        b++;
    }
    
    return b;
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
      static NSString *Identifier = @"InviteFriendCell";
      InviteFriendCell *cell = (InviteFriendCell*)[tableView dequeueReusableCellWithIdentifier:Identifier];
      if(cell==nil)
       {
          NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"InviteFriendCell" owner:nil options:nil];
          cell=[topLevelObjects firstObject];
       }

     if (selectedIndexpath&& indexPath.row==selectedIndexpath.row) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
      }
     else
     {
        cell.accessoryType=UITableViewCellAccessoryNone;
      }
    NSDictionary*nameDict = [arrFreinds objectAtIndex:indexPath.row];//[dict objectForKey:@"username"];

    if ([[nameDict objectForKey:@"status"]isEqualToString:@"online"]) {
        
        cell.btnStatus.selected=YES;
    }
    else
    {
        cell.btnStatus.selected=NO;
    }
    if (nameDict) {
     cell.lblName.text=[nameDict objectForKey:@"username"];
     }
        return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    InviteFriendCell *cell=(InviteFriendCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType==UITableViewCellAccessoryCheckmark) {
        
        cell.accessoryType=UITableViewCellAccessoryNone;
        selectedIndexpath=nil;
    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        selectedIndexpath=indexPath;
        dictSelectedUser=[arrFreinds objectAtIndex:indexPath.row];
    }
    
    [tblView reloadData];
}



-(IBAction)btnInviteFriendClicked:(id)sender
{
    
    if (selectedIndexpath) {
        
        [self sendInvitationToSelectedUser];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"Sending Invitation"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        int duration = 1.5; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:^{
              
                //[self gotoGameVC];
            }];
            
            
        });

        
    }
    else
    {
        [ObjApp_Delegate showAlertView:nil strMessage:@"Please select user to send invitation"];
    }
    
    //[self createDragableView];
}


-(void)gotoGameVC
{
//    if (self.isOnline) {
        
        ViewController *vc=[[ViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
//     }
//    else
//    {
//        OfflineGameVC *push=[[OfflineGameVC alloc]initWithNibName:@"OfflineGameVC" bundle:nil];
//        [self.navigationController pushViewController:push animated:YES];
//
//    }

}

-(void)createDragableView
{
    draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(0, 100, 320, 320)];
    [draggableBackground loadCards];
    [self.view addSubview:draggableBackground];
 }


-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getFbFriends
{
    selectedIndexpath=nil;
    dictSelectedUser=nil;
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
    [tblView.pullToRefreshView stopAnimating];

    arrFreinds =[[NSMutableArray alloc]init];
    
    if ([dictRes isKindOfClass:[NSDictionary class]])
    {
        if ([[dictRes objectForKey:@"status"]integerValue]==1)
        {
            NSMutableArray *arrOff=[dictRes objectForKey:@"offline_friend"];
            NSMutableArray *arrf=[dictRes objectForKey:@"user_friend"];
 

            if (arrOff.count==0)
            {
                
           UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No friends found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=123;
            [alert show];

            }
            else
            {
                
                for (int i=0; i<arrf.count; i++) {
                    NSDictionary *dict=[arrf objectAtIndex:i];
                    NSMutableDictionary *dictN=[[NSMutableDictionary alloc]init];
                    [dictN setObject:[dict objectForKey:@"id"] forKey:@"id"];
                    [dictN setObject:[dict objectForKey:@"username"] forKey:@"username"];
                    [dictN setObject:@"online" forKey:@"status"];
                    [arrFreinds addObject:dictN];
                }

                for (int i=0; i<arrOff.count; i++) {
                    NSDictionary *dict=[arrOff objectAtIndex:i];
                    
                    if([[dict objectForKey:@"is_online"] isEqualToString:@"N"])
                    {
                        NSMutableDictionary *dictN=[[NSMutableDictionary alloc]init];
                        [dictN setObject:[dict objectForKey:@"id"] forKey:@"id"];
                        [dictN setObject:[dict objectForKey:@"username"] forKey:@"username"];
                        [dictN setObject:@"offline" forKey:@"status"];
                        [arrFreinds addObject:dictN];
                    }
                }

                 App_Delegate.currentUser.arrFriends=arrFreinds;
                 [tblView reloadData];
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




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==123) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag==456)
    {
        if (nodataleft) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}




#pragma mark Offline Game Methods

// this method will call the api to get details of pending

//{"game_id":1157,"user_id":55,"player_type":"user/oponent"}



-(IBAction)btnPendingRequestClicked
{
    PendingRequestsVC *Vc=[[PendingRequestsVC alloc]init];
    [self.navigationController presentViewController:Vc animated:YES completion:nil];
}

-(void)sendInvitationToSelectedUser
{

    // if user is not online then send a push notification to user to come online, it was changed in final changes
    if ([[dictSelectedUser objectForKey:@"status"] isEqualToString:@"offline"]) {
        [self notifyUserTocomeOnline];
    }
    else
    {
        // else send the invitation to play the game online
        NSMutableDictionary *dictRes=[[NSMutableDictionary alloc]init];
        [dictRes setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
        [dictRes setObject:[dictSelectedUser objectForKey:@"id"] forKey:@"opponent_id"];
        [dictRes setObject:@"FB" forKey:@"player_type"];
        [dictRes setObject:[dictSelectedUser objectForKey:@"username"] forKey:@"user_name"];
        [dictRes setObject:@"online" forKey:@"mode"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictRes options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *strMessageID=[App_Delegate getMessageID];
        [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITE_USER Body:myString withID:strMessageID];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
}


-(void)notifyUserTocomeOnline
{
//
    NSMutableDictionary *dictRes=[[NSMutableDictionary alloc]init];
    [dictRes setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dictRes setObject:[dictSelectedUser objectForKey:@"id"] forKey:@"opponent_id"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictRes options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITE_SEND_NOTIFICATION Body:myString withID:strMessageID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

}


#pragma mark start Game Notification

-(void)startTheGameNow:(NSNotification*)notification
{

    NSDictionary *dict=notification.object;
    
    
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
    NSLog(@"GMT TIME IS %@ and normal date is %@",systDate,[NSDate date]);

    NSLog(@"Response of Game Start Subject%@",dict);
}



//  NSLog(@"Response of Game Start Subject%@",dict);





-(void)GotoGamescreen:(NSDictionary*)dict
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    App_Delegate.objGameOnline=(ViewController*)[App_Delegate getGameViewControllerObject:NO];
    App_Delegate.objGameOnline.dictMain=dict;
    [App_Delegate changeRootVieController:App_Delegate.objGameOnline];

}


-(void)invitationRejected
{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Game Invitation Rejected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag=456;
    [alert show];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



#pragma send Notification to friend to come online

-(void)sentNotificationToComeOnline:(NSNotification*)noti
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Notification sent"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    int duration = 1.5; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
            
            //[self gotoGameVC];
        }];
        
        
    });

}


@end
