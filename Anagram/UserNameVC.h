//
//  UserNameVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserNameVC : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *txtUserName;
}
@property(nonatomic,strong)NSMutableDictionary *dictInfo;
@end
