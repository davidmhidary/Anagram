//
//  LoginVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface LoginVC : UIViewController<UITextFieldDelegate>

{
    AppDelegate *app;
    IBOutlet UITextField *txtEmail,*txtPassword;
}
@end
