//
//  NotelrIAPHelper.m
//  Note'lr
//
//  Created by Ali Yılmaz on 07/05/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

#import "WhoViewedAPHelper.h"

@implementation WhoViewedAPHelper


+ (WhoViewedAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static WhoViewedAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      k5CrownsPurchase,
                                      k25CrownsPurchase,
                                      k100CrownsPurchase,
                                      k500CrownsPurchase,
                                      kUnlimitedCrownsPurchase,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


/*
+ (WhoViewedAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static WhoViewedAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.showtop10list.app",
                                      @"com.newtop20list.app",
                                      @"com.showfulllist.app",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}
*/

@end


/*
 #define kInAppTop10 @"com.showtop10list.app"
 #define kInAppTop20 @"com.newtop20list.app"  //:-$4.99       //com.showtop20list.app :- $3.99
 #define kInAppFullList @"com.showfulllist.app"
 #define kInAppRemoveAds @"com.removeallads.app"
 
 */