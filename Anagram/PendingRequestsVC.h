//
//  PendingRequestsVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 01/09/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingRequestsVC : UIViewController
{
    NSMutableArray *arrPendingGames;
    
    IBOutlet UITableView *tblList;
    
    IBOutlet UILabel*lblPendingRequestsLabel;
}
@end
