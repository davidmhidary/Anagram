//
//  AcceptTurnBasedPopUpVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 06/09/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "AcceptTurnBasedPopUpVC.h"

@interface AcceptTurnBasedPopUpVC ()

@end

@implementation AcceptTurnBasedPopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationReceived:) name:INVITE_USER object:nil];

    [self performSelector:@selector(removeAcceptNotificationView) withObject:nil afterDelay:30.0];
    // Do any additional setup after loading the view from its nib.
}

/*
-(IBAction)getPendigGames_Details:(UIButton*)btnSender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSDictionary *dictDetails=self.dictPayload;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (App_Delegate.currentUser.userID)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
        [dict setObject:[dictDetails objectForKey:@"game_id"] forKey:@"game_id"];
        [APIsList sendJasonDATa:dict url:getOfflineGameDetails Selector:@selector(callBackGetOfflineGameDetails:) WithCallBackObject:self];
    }
  
}
-(void)callBackGetOfflineGameDetails:(NSDictionary*)dictRes
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([dictRes isKindOfClass:[NSDictionary class]]) {
        
        if ([[dictRes objectForKey:@"status"]integerValue]==1) {
            ObjApp_Delegate.objGameOffline=(OfflineGameVC*)[ObjApp_Delegate getGameViewControllerObject:NO];
            ObjApp_Delegate.objGameOffline.dictMain=dictRes;
            [ObjApp_Delegate changeRootVieController:ObjApp_Delegate.objGameOffline];
        }
    }
    else
    {
        [App_Delegate showAlertView:@"Error!" strMessage:[dictRes objectForKey:@"message"]];
    }
}
*/


-(void)invitationReceived:(NSNotification*)notification
{
    
    //{"game_id":"7","opponent_id":"22"}
    
    infoDict=notification.object;
    NSLog(@"response %@",infoDict);
    
    self.lablName.text=[NSString stringWithFormat:@"%@ wants to play with you",[infoDict objectForKey:@"username"]];
}



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
    
    //  NSLog(@"Response of Game Start Subject%@",dict);
    
    

    
    
    
}



-(void)GotoGamescreen:(NSDictionary*)dict
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    App_Delegate.objGameOnline=(ViewController*)[App_Delegate getGameViewControllerObject:YES];
    App_Delegate.objGameOnline.dictMain=dict;
    App_Delegate.objGameOnline.isOpponent=YES;
    [App_Delegate changeRootVieController:App_Delegate.objGameOnline];
    [self.view removeFromSuperview];
    
}


-(IBAction)btnAcceptInvitaionClicked:(id)sender
{
    [self sendGameQuittedPacket];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnRejectInvitaionClicked:) object:nil];
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"opponent_id"];
    [dict setObject:[infoDict objectForKey:@"game_id"] forKey:@"game_id"];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITATION_ACCEPTED Body:myString withID:strMessageID];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(IBAction)btnRejectInvitaionClicked:(id)sender
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"opponent_id"];
    [dict setObject:[infoDict objectForKey:@"game_id"] forKey:@"game_id"];
    
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITATION_REJECTED Body:myString withID:strMessageID];
    
    [self.view removeFromSuperview];
}


-(void)sendGameQuittedPacket
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    if (ObjApp_Delegate.currentGameId) {
        [dict setObject:ObjApp_Delegate.currentGameId forKey:@"game_id"];

    }
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:Game_Quit_User Body:myString withID:strMessageID];
    
    
}


-(void)removeAcceptNotificationView
{
    [self.view removeFromSuperview];
}


@end
