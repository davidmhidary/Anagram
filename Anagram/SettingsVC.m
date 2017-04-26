//
//  SettingsVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 18/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "SettingsVC.h"
#import "AboutVC.h"
@interface SettingsVC ()

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButtonsSelectedOrNot];
    // Do any additional setup after loading the view from its nib.
}

-(void)setButtonsSelectedOrNot
{
  //  NSString *turnBased=[Anagrams_Defaults objectForKey:isTurnBasedGame];
    NSString *soundOn  =[Anagrams_Defaults objectForKey:isGameSoundOn];
    NSString *notifiOn =[Anagrams_Defaults objectForKey:isGamePushNotiOn];

//    if ([turnBased isEqualToString:@"YES"]) {
//        btnLiveOrTurnBased.selected=YES;
//    }
//    else
//    {
//        btnLiveOrTurnBased.selected=NO;
//    }
    if ([soundOn isEqualToString:@"YES"]) {
        btnSound.selected=NO;
    }
    else
    {
        btnSound.selected=YES;
    }
    if ([notifiOn isEqualToString:@"YES"]) {
        btnNotification.selected=YES;
    }
    else
    {
        btnNotification.selected=NO;
    }
    
 
}
-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnAboutClicked:(id)sender
{
    AboutVC *aVC=[[AboutVC alloc]init];
    [self.navigationController pushViewController:aVC animated:YES];
}


-(IBAction)btnTurnsPressed:(UIButton*)sender
{
    NSString *strisTurnBased=@"NO";
    if (sender.selected)
    {
        sender.selected=NO;
        strisTurnBased=@"NO";
    }
    else
    {
        sender.selected=YES;
        strisTurnBased=@"YES";
    }
    
//    [Anagrams_Defaults setObject:strisTurnBased forKey:isTurnBasedGame];
//    [Anagrams_Defaults synchronize];
}
-(IBAction)btnSoundsPressed:(UIButton*)sender
{
    NSString *strisSoundOn=@"NO";
    if (sender.selected)
    {
        sender.selected=NO;
        strisSoundOn=@"YES";
     }
    else
    {
        sender.selected=YES;
        strisSoundOn=@"NO";
    }
    
    [Anagrams_Defaults setObject:strisSoundOn forKey:isGameSoundOn];
    [Anagrams_Defaults synchronize];

}


-(IBAction)btnNotificationClicked:(UIButton*)sender
{
     if (sender.selected)
    {
        sender.selected=NO;
        
     //   [ObjApp_Delegate doNotificationsStuffHere];
     }
    else
    {
        sender.selected=YES;
        
        [[UIApplication sharedApplication]unregisterForRemoteNotifications];
     }
    

}

-(IBAction)showInfoViewForTurnBasedAndLiveGame
{
    //Set Animatio
    
    vWInfo.hidden=NO;
    vWInfo.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    vWInfo.alpha=0;
    
    
    [UIView animateWithDuration:0.3  animations:^{
        
        vWInfo.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        vWInfo.alpha=1;
         [self.view addSubview:vWInfo];
    }];

}


-(IBAction)removeInfoView:(id)sender
{
    vWInfo.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    vWInfo.alpha=1;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        vWInfo.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        vWInfo.alpha=0;
    }completion:^(BOOL finished) {
       
        [vWInfo removeFromSuperview];

    }];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
