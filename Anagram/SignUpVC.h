//
//  SignUpVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpVC : UIViewController
{
 
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    //
    IBOutlet UIView *vwPushNotification;

}

@property (nonatomic,strong)NSString *strEmail;
@end
