//
//  ContactsData.m
//  WhoHasMe
//
//  Created by Purushottam Sain on 17/07/14.
//  Copyright (c) 2014 Square Bits ( Developer : Purushottam Sain ). All rights reserved.
//

#import "ContactsData.h"

@implementation ContactsData

@synthesize strEmail,strFirstName,strLastName,imgUserImage,strPhoneNumber;

-(id)initWithDefaults
{
    strEmail=@"No Email";
    strFirstName=@"No First Name";
    strLastName=@"No Last Name";
    strPhoneNumber=@"No Phone";
    imgUserImage=[UIImage imageNamed:@"blank_profilepic.png"];
    
    
    return self;
    
    
}


@end
