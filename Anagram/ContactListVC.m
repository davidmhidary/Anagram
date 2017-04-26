//
//  ContactListVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 28/11/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "ContactListVC.h"
#import "ContactsCell.h"
@interface ContactListVC ()

@end

@implementation ContactListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestContactPermission];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - TableView Delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsCell *cell=(ContactsCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactsCell"];
    
    if (cell==nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ContactsCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (ContactsCell*)currentObject;
                break;
            }
        }
        
    }
    //For change font of MyFriendCell
    
    
    ContactsData *contactData=(ContactsData*)[items objectAtIndex:indexPath.row];
    cell.lblName.text=[NSString stringWithFormat:@"%@ %@",contactData.strFirstName,contactData.strLastName];
    
    cell.btnInvite.tag=indexPath.row;
    
    [cell.btnInvite addTarget:self action:@selector(sendMessageToInviteUser:) forControlEvents:UIControlEventTouchUpInside ];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return items.count;
    
}


// Height of cell in pixels
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
    
}

-(void)sendMessageToInviteUser:(UIButton*)sender
{
    ContactsData *contactData=[items objectAtIndex:sender.tag];
    
    NSString *number=contactData.strPhoneNumber;
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"Hi, let's play Anagrams.io together. Download it here *link*";
        controller.recipients = [NSArray arrayWithObjects:number, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIButtonAction

-(void)requestContactPermission
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                 items= [self getAllContacts];
                
                [tblView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

            }
            else
            {
                // User denied access
                // Display an alert telling user the contact could not be added
                //                [AppDelegate showALERT:@"You denied the contact request, Please go to setting and the change the privacy."];
                [[[UIAlertView alloc]initWithTitle:@"" message:@"You denied the contact request, Please go to setting and the change the privacy." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                
                
            }
        });
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
       items= [self getAllContacts];
        
        [tblView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        
        [[[UIAlertView alloc]initWithTitle:@"" message:@"You had denied the contact request, Please go to setting and the change the privacy." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}




-(NSMutableArray *)getAllContacts
{
    
    
    
    
    
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        //   NSLog(@"Fetching contact info ----> ");
#endif
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        //CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        CFIndex nPeople = CFArrayGetCount(allPeople);
        
        items = [NSMutableArray arrayWithCapacity:nPeople];
        
        NSLog(@"Total number of records : %ld",nPeople);
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        
        dispatch_async(backgroundQueue, ^{
            
            
            for (int i = 0; i < nPeople; i++)
            {
                ContactsData *contacts = [[ContactsData alloc]initWithDefaults];
                
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                
                //get First Name and Last Name
                if (person && person!=(__bridge ABRecordRef)((id)[NSNull null]))
                {
                    
                    NSLog(@"checking of records at : %d",i);
                    NSString *str= (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    NSLog(@"Name : %@",str);
                    
                    
                    if ((__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty) && (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty)!=(id)[NSNull null])
                    {
                        contacts.strFirstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                        
                    }
                    else
                    {
                        contacts.strFirstName=@"";
                    }
                    
                    NSString *strLastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    
                    if (strLastName && strLastName!=(id)[NSNull null])
                    {
                        contacts.strLastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    }
                    else
                    {
                        contacts.strLastName=@"";
                    }
                    
                    if (!contacts.strFirstName) {
                        contacts.strFirstName = @"";
                    }
                    if (!contacts.strLastName) {
                        contacts.strLastName = @"";
                    }
                    
                    // get contacts picture, if pic doesn't exists, show standart one
                    
                    NSData  *imgData = (__bridge NSData* )ABPersonCopyImageData(person);
                    contacts.imgUserImage = [UIImage imageWithData:imgData];
                    if (!contacts.imgUserImage) {
                        contacts.imgUserImage = [UIImage imageNamed:@"ic_profile_contact.png"];
                    }
                    //get Phone Numbers
                    
                    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
                    
                    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                        
                        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                        NSString *phoneNumber = (__bridge NSString* ) phoneNumberRef;
                        [phoneNumbers addObject:phoneNumber];
                        
                        // NSLog(@"All numbers %@", phoneNumbers);
                        if (contacts.strPhoneNumber) {
                            contacts.strPhoneNumber =phoneNumber;
                        }
                        
                        
                    }
                     //get Contact email
                    
                    NSMutableArray *contactEmails = [NSMutableArray new];
                    ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
                    
                    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                        CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                        NSString *contactEmail = (__bridge NSString* )contactEmailRef;
                        
                        [contactEmails addObject:contactEmail];
                        //NSLog(@"All emails are:%@", contactEmails);
                        
                    }
                     [items addObject:contacts];
                 }
                else
                {
                    NSLog(@"Ignored contact");
                }
             }
            

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                [tblView reloadData];
 
            });
        });

        
        return items;

    }
    else
    {
        
        //    NSLog(@"Cannot fetch Contacts :( ");
        
        return nil;
    }
    
}


-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
