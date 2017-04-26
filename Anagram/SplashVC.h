//
//  SplashVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 21/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface SplashVC : UIViewController<UIAlertViewDelegate>
{
    IBOutlet UIImageView *imgBG;
    AppDelegate *app;
    
 IBOutlet   UIActivityIndicatorView *indicator;
}
@end
