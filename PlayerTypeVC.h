//
//  PlayerTypeVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DraggableViewBackground.h"

@interface PlayerTypeVC : UIViewController
{
    AppDelegate *app;
    
    IBOutlet UIView *viewFbLogin,*viewNAtiveLogin;
    DraggableViewBackground *draggableBackground;

}
@end
