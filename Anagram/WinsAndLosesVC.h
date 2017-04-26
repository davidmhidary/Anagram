//
//  WinsAndLosesVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 30/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinsAndLosesVC : UIViewController
{
    NSMutableArray *arrPendingGames;
    
    IBOutlet UITableView *tblList;
}
@end
