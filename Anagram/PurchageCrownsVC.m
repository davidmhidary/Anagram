//
//  PurchageCrownsVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "PurchageCrownsVC.h"
#import "BuyCrownsCell.h"
#import "IAPHelper.h"
#import "WhoViewedAPHelper.h"
@interface PurchageCrownsVC ()

@end

@implementation PurchageCrownsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    arrCrowns  = [NSArray arrayWithObjects:@"25",@"125",@"375",@"800",@"2000",@"UNLIMITED", nil];
    arrCosts = [NSArray arrayWithObjects:@".99",@"4.99",@"9.99",@"19.99",@"39.99",@"99.99", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseSuccedded:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:IAPHelperProductPurchaseFailedNotification object:nil];

    
    NSInteger crowns=[Anagrams_Defaults integerForKey:kNumberOfCrowns];
    if (crowns>0) {
        lblCrowns.text=[NSString stringWithFormat:@"%ld",(long)crowns];
    }
    else
    {
        lblCrowns.text=@"0";
    }
    // Do any additional setup after loading the view from its nib.
}



-(void)viewDidAppear:(BOOL)animated
{
    if ([[UIScreen mainScreen ]bounds].size.height<500)
    {
        SCRL.contentSize=CGSizeMake(self.view.frame.size.width, 568);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCrowns.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"BuyCrownsCell";
    
    BuyCrownsCell *cell = (BuyCrownsCell*)[tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if(cell==nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"BuyCrownsCell" owner:nil options:nil];
        
        
        cell=[topLevelObjects firstObject];
    }
    
    cell.lblCost.text   = [arrCosts objectAtIndex:indexPath.row];
    cell.lblCrowns.text = [arrCrowns objectAtIndex:indexPath.row];
    
    return cell;
}




-(IBAction)btnCrownsClicked:(UIButton*)sender
{
    switch (sender.tag) {
        case 101:
        {
            currentCrowns=5;
            [self purchaseProduct:k5CrownsPurchase ];
            
        }
            break;
        case 102:
        {
            currentCrowns=25;

            [self purchaseProduct:k25CrownsPurchase ];
        }
            break;
        case 103:
        {
            
            currentCrowns=100;

            [self purchaseProduct:k100CrownsPurchase ];
   
        }
            break;
        case 104:
        {
            currentCrowns=500;

            [self purchaseProduct:k500CrownsPurchase ];
            
        }
            break;
        case 105:
        {
            currentCrowns=0;
            isUnlimited=YES;
            [self purchaseProduct:kUnlimitedCrownsPurchase ];
        }
            break;
            
        default:
            break;
    }
}


-(void)purchaseProduct:(NSString*)inappProductId
{
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[WhoViewedAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if (success)
         {
             // NSLog(@"%@", products);
             if (products.count > 0)
             {
                 for (SKProduct *p in products)
                 {
                     if ([p.productIdentifier isEqualToString:inappProductId])
                     {
                         [[WhoViewedAPHelper sharedInstance] buyProduct:p];
                     }
                 }
             }
             else
             {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             }
         }
     }];

}

#pragma mark InappSuccessornotMethods

- (void)purchaseSuccedded:(NSNotification *)notification
{
    NSInteger crowns=[Anagrams_Defaults integerForKey:kNumberOfCrowns];
    
    crowns=crowns+currentCrowns;
 
    [Anagrams_Defaults setInteger:crowns forKey:kNumberOfCrowns];
    [Anagrams_Defaults synchronize];
    
    if (crowns>0) {
        lblCrowns.text=[NSString stringWithFormat:@"%ld",(long)crowns];
    }

    if (isUnlimited)
    {

        isUnlimited=NO;
        [Anagrams_Defaults setObject:@"YES" forKey:kIsUnlimitedCrownsAdded];
        [Anagrams_Defaults synchronize];

    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)purchaseFailed:(NSNotification *)notification
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Purchase" message:@"Purchase failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertView show];
}



-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
