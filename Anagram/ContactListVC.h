//
//  ContactListVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 28/11/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsData.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
@interface ContactListVC : UIViewController<MFMessageComposeViewControllerDelegate>
{
    NSMutableArray *aryContacts, *arrSearch,*items;
    
    IBOutlet UITableView *tblView;

}
@end
