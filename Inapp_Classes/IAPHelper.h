//
//  IAPHelper.h
//  Notelr
//
//  Created by Ali Yılmaz on 07/05/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

#import <StoreKit/StoreKit.h>
//#import "VerificationController.h"
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchaseRestoredNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchaseFailedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchaseRestoreFailedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject
{
    BOOL isPurchasedInApp;
}
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
-(BOOL)restore;

@end