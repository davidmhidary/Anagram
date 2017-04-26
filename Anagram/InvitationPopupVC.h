//
//  InvitationPopupVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 07/06/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "ViewController.h"

@interface InvitationPopupVC : UIViewController
{
    NSDictionary *infoDict;
}

@property(nonatomic,strong)IBOutlet UILabel *lblUserName;
@property(nonatomic,strong)IBOutlet UILabel *lblScore;
@property(nonatomic,strong)IBOutlet UIImageView *imgInvitee;

@end
