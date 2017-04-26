//
//  ContactsData.h
//  WhoHasMe
//
//  Created by Purushottam Sain on 17/07/14.
//  Copyright (c) 2014 Square Bits ( Developer : Purushottam Sain ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactsData : NSObject

@property (nonatomic,strong) NSString *strFirstName;
@property (nonatomic,strong) NSString *strLastName;
@property (nonatomic,strong) NSString *strEmail;
@property (nonatomic,strong) NSString *strPhoneNumber;
@property (nonatomic,strong) UIImage *imgUserImage;

@property (nonatomic, strong) NSMutableArray *arrContactData;
-(id)initWithDefaults;


@end
