//
//  ContactVC.h
//  LastSeen
//
//  Created by Manish Sawlot on 23/08/16.
//  Copyright © 2016 Deepak Pal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ContactsData.h"
#import <AddressBook/AddressBook.h>

@interface ContactVC : UIViewController<UITextFieldDelegate>
{
NSMutableArray *aryContacts, *arrSearch,*items;
    
    IBOutlet UITableView *tblView;
 }


@end
