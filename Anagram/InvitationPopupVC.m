//
//  InvitationPopupVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 07/06/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "InvitationPopupVC.h"
#import "HomeVC.h"
#import "UIImageView+WebCache.h"

@interface InvitationPopupVC ()

@end

@implementation InvitationPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationReceived:) name:INVITE_USER object:nil];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];

    self.imgInvitee.layer.cornerRadius=85;
    self.imgInvitee.layer.masksToBounds=YES;
    
    
    // the invitation  popup will be cancelled automatically after 60 seconds, if user does respond.
    
    [self performSelector:@selector(btnRejectInvitaionClicked:) withObject:nil afterDelay:60.0];
}




-(void)invitationReceived:(NSNotification*)notification
{
    
    //{"game_id":"7","opponent_id":"22"}
    
    infoDict=notification.object;
     NSLog(@"response %@",infoDict);

    self.lblUserName.text=[infoDict objectForKey:@"username"];
    self.lblScore.text=[NSString stringWithFormat:@"High Score: %@",[infoDict objectForKey:@"score"]];
   [self.imgInvitee sd_setImageWithURL:[NSURL URLWithString:[infoDict objectForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:@"profile_pic_placeholder.png"]];
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
