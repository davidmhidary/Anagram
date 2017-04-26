//
//  FriendsListVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewBackground.h"

@interface FriendsListVC : UIViewController
{
    DraggableViewBackground *draggableBackground;
    
    IBOutlet UITableView *tblView;
    IBOutlet UITableView *tblPendingRequest;
    
    IBOutlet UIView *vwPendingRequest;
    
    NSMutableArray *arrFreinds;
     BOOL nodataleft;
    
    IBOutlet UIButton *btnInvite;
    IBOutlet UIButton *btnPendingRequests;
    
    NSIndexPath *selectedIndexpath;

    NSDictionary *dictSelectedUser;
}

@property BOOL shouldHidePendigReqbtn;
@property BOOL isOnline;

@end
