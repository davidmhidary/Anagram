//
//  HomeVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
@interface HomeVC : UIViewController<UIAlertViewDelegate>
{
    AppDelegate *app;
    NSString *strWordOfDay;
    
    IBOutlet UIButton *btnSwithLiveTurn;
    IBOutlet UIButton *btnPlayLiveTurnTab;
    
    IBOutlet UILabel *lblWordOfDay;
    IBOutlet UILabel *lblNumberOfPoints;
    
    IBOutlet UILabel *lblTurnLive;
    IBOutlet UILabel *lblFBConnected;
    
    IBOutlet UILabel *lblWelcomeUser;
    
    AVAudioPlayer *player;

    IBOutlet UIScrollView *scrl;
    
}
@end
