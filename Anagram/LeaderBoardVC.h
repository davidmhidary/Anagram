//
//  LeaderBoardVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKShareKit/FBSDKShareKit.h>

@interface LeaderBoardVC : UIViewController<FBSDKSharingDelegate>
{
    IBOutlet UITableView *tblData;
    NSMutableArray *arrUsersData;
    IBOutlet UILabel *lblScore,*lblName;
    
    int page;
    NSString *strCurrentValue;
    IBOutlet UIButton *btnFb,*btnWorld;
    IBOutlet UILabel *lblHighScores;
}
@end
