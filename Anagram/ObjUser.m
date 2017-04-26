//
//  ObjUser.m
//  Anagram
//
//  Created by Ashok Choudhary on 30/05/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "ObjUser.h"

@implementation ObjUser



+(ObjUser*)currentObject
{
    static dispatch_once_t pred;
    static ObjUser *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[ObjUser alloc] init];
        
    });
     return sharedInstance;
}


-(void)clearObjectData
{
    self.userPassword=@"";
    self.userAuthKey=@"";
    self.userEmail=@"";
    self.userFName=@"";
    self.userID=@"";
    self.userLName=@"";
    self.userName=@"";
    self.currentGameId=@"";
    self.arrFriends=[[NSMutableArray alloc]init];
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    
    [encoder encodeObject:self.userAuthKey forKey:@"userAuthKey"];
    [encoder encodeObject:self.userPassword forKey:@"userPassword"];
    [encoder encodeObject:self.userFBID forKey:@"userFBID"];

    [encoder encodeObject:self.userEmail forKey:@"userEmail"];
    [encoder encodeObject:self.userFName forKey:@"userFName"];
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.userLName forKey:@"userLName"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.currentGameId forKey:@"currentGameId"];
    
    [encoder encodeObject:self.arrFriends forKey:@"arrFriends"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init]))
    {

        self.userAuthKey = [decoder decodeObjectForKey:@"userAuthKey"];
        self.userPassword = [decoder decodeObjectForKey:@"userPassword"];
        self.userFBID = [decoder decodeObjectForKey:@"userFBID"];

        self.userEmail = [decoder decodeObjectForKey:@"userEmail"];
        self.userFName = [decoder decodeObjectForKey:@"userFName"];
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.userLName = [decoder decodeObjectForKey:@"userLName"];
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.currentGameId = [decoder decodeObjectForKey:@"currentGameId"];

        self.arrFriends = [decoder decodeObjectForKey:@"arrayOfClasses"];
    }
    return self;
}




@end
