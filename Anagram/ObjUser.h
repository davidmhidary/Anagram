//
//  ObjUser.h
//  Anagram
//
//  Created by Ashok Choudhary on 30/05/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjUser : NSObject



@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *userFName;
@property(nonatomic,strong)NSString *userLName;
@property(nonatomic,strong)NSString *userEmail;
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *currentGameId;
@property(nonatomic,strong)NSString *userAuthKey;

@property(nonatomic,strong)NSString *userJID;
@property(nonatomic,strong)NSString *userPassword;
@property(nonatomic,strong)NSString *userFBID;


@property (nonatomic,strong)NSMutableArray *arrFriends;
+(ObjUser*)currentObject;
-(void)clearObjectData;

@end
