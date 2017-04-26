//
//  IAPHelper.m
//  Notelr
//
//  Created by Ali Yılmaz on 07/05/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "NSData+Base64.h"
#import "VerificationController.h"
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductPurchaseRestoredNotification = @"IAPHelperProductPurchaseRestoredNotification";
NSString *const IAPHelperProductPurchaseFailedNotification = @"IAPHelperProductPurchaseFailedNotification";
NSString *const IAPHelperProductPurchaseRestoreFailedNotification = @"IAPHelperProductPurchaseRestoreFailedNotification";

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

// 3
@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                //NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                //NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    //NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
//    for (SKProduct * skProduct in skProducts) {
//        //NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
//        
//    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    //NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (transactions.count>1)
    {
        // it may be case of restore
        SKPaymentTransaction * lastTransaction = [transactions lastObject];
        NSDate *maxDate = [NSDate dateWithTimeIntervalSince1970:0];
        for (SKPaymentTransaction * transaction in transactions)
        {
            NSLog(@"transactoinDate %@",transaction.transactionDate);
            if ([transaction.transactionDate timeIntervalSinceDate:maxDate]>0)
            {
                maxDate = transaction.transactionDate;
                lastTransaction = transaction;
            }
        }
        
        switch (lastTransaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:lastTransaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:lastTransaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:lastTransaction];
                break;
            default:
                break;
        }
        
    }
    else
    {
        for (SKPaymentTransaction * transaction in transactions)
        {
            switch (transaction.transactionState)
            {
                case SKPaymentTransactionStatePurchased:
                    [self completeTransaction:transaction];
                    break;
                case SKPaymentTransactionStateFailed:
                    [self failedTransaction:transaction];
                    break;
                case SKPaymentTransactionStateRestored:
                    [self restoreTransaction:transaction];
                default:
                    break;
            }
        }
    }
    
}
-(BOOL)restore{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    return YES;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *strBase64 = [receipt base64forData];
    
//    [Anagrams_Defaults setObject:transaction.payment.productIdentifier forKey:kInAppTransaction_ProductIdentifire];
//    [Anagrams_Defaults setObject:transaction.transactionIdentifier forKey:kInAppTransaction_Id];
//    [Anagrams_Defaults setObject:transaction.payment.productIdentifier forKey:kInAppTransaction_ProductIdentifire];
//    if (transaction.originalTransaction)
//    {
//        [Anagrams_Defaults setObject:transaction.originalTransaction.transactionIdentifier forKey:kInAppTransaction_Id];
//    }
//    
//    [Anagrams_Defaults setObject:strBase64 forKey:kInAppAppStroreReceipt];
//    [Anagrams_Defaults synchronize];
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier userInfo:nil];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *strBase64 = [receipt base64forData];
    
//    [NS_Defaults setObject:transaction.payment.productIdentifier forKey:kInAppTransaction_ProductIdentifire];
//    [NS_Defaults setObject:transaction.transactionIdentifier forKey:kInAppTransaction_Id];
//    if (transaction.originalTransaction)
//    {
//        [NS_Defaults setObject:transaction.originalTransaction.transactionIdentifier forKey:kInAppTransaction_Id];
//    }
//    
//    [NS_Defaults setObject:strBase64 forKey:kInAppAppStroreReceipt];
//    [NS_Defaults synchronize];
    
    
    NSLog(@"restored product %@",transaction.originalTransaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseRestoredNotification object:transaction.originalTransaction.payment.productIdentifier userInfo:nil];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    //NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        //NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseFailedNotification object:transaction.error.localizedDescription userInfo:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction
{
    
    VerificationController * verifier = [VerificationController sharedInstance];
    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
        if (success)
        {
            //NSLog(@"Successfully verified receipt!");
            
            if (isPurchasedInApp)
            {
                [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier userInfo:nil];
                
            }
            else
            {
                [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
                 [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseRestoredNotification object:transaction.originalTransaction.payment.productIdentifier userInfo:nil];
               
            }
        }
        else
        {
            //NSLog(@"Failed to validate receipt.");
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseFailedNotification object:transaction.error.localizedDescription userInfo:nil];
        }
    }];
}


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseRestoreFailedNotification object:nil userInfo:nil];
}

@end