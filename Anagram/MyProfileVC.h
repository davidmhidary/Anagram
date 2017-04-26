//
//  MyProfileVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 29/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileVC : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    IBOutlet UIImageView *imgProfile;
    IBOutlet UITextField *txtUserName;
    
    IBOutlet UILabel *lblHighScore;
}
@end
