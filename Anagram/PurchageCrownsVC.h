//
//  PurchageCrownsVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchageCrownsVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrCosts,*arrCrowns;
    
    IBOutlet UIScrollView *SCRL;
    
    IBOutlet UILabel *lblCrowns;
    
    int currentCrowns;
    BOOL isUnlimited;
}
@end
