//
//  LoginSignUpVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginSignUpVC : UIViewController
{
    IBOutlet UITextField *txtEmail;
    
    NSMutableDictionary *dictFBUserInfo;
}
@end
