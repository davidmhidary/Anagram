//
//  PendingRequestsVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 01/09/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "PendingRequestsVC.h"
#import "PendingRequestCell.h"

@interface PendingRequestsVC ()

@end

@implementation PendingRequestsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self callAPIgetPendingGamesList];
    // Do any additional setup after loading the view from its nib.
}


-(void)callAPIgetPendingGamesList
{
    NSString *strUrl=getPendingGamesList;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:App_Delegate.currentUser.userID forKey:@"user_id"];
    [APIsList sendJasonDATa:dict url:strUrl Selector:@selector(callBackPendingList:) WithCallBackObject:self];
}

-(void)callBackPendingList:(NSMutableDictionary*)dicRes
{
    if ([[dicRes objectForKey:@"status"]integerValue]==1) {
        
        NSMutableArray *arrPendingList=[dicRes objectForKey:@"game"];
        
        arrPendingGames =[[NSMutableArray alloc]init];
        for(NSDictionary *dict in arrPendingList)
        {
            if ([[dict objectForKey:@"status"]isEqualToString:@"WAITING"]) {
                
                [arrPendingGames addObject:dict];
            }
        }
        
        lblPendingRequestsLabel.text=[NSString stringWithFormat:@"PENDING REQUESTS(%lu)",(unsigned long)arrPendingGames.count];
        [tblList reloadData];
    }
    else
    {
        [App_Delegate showAlertView:@"" strMessage:[dicRes objectForKey:@"message"]];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return arrPendingGames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
         static NSString *Identifier = @"PendingRequestCell";
        
        PendingRequestCell *cell = (PendingRequestCell*)[tableView dequeueReusableCellWithIdentifier:Identifier];
        
        if(cell==nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"PendingRequestCell" owner:nil options:nil];
            
            
            cell=[topLevelObjects firstObject];
        }
      NSDictionary* dict=[arrPendingGames objectAtIndex:indexPath.row];
      NSLog(@"%@",[dict objectForKey:@"id"]);
      cell.lblGameOwnerName.text=@"Anagram User";
      [cell.btnAccept addTarget:self action:@selector(getPendigGames_Details:) forControlEvents:UIControlEventTouchUpInside];
      cell.btnAccept.tag=indexPath.row;
        return cell;
        
     
}

-(IBAction)getPendigGames_Details:(UIButton*)btnSender
{

    NSDictionary *dictDetails=[arrPendingGames objectAtIndex:btnSender.tag];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (App_Delegate.currentUser.userID)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
        [dict setObject:[dictDetails objectForKey:@"id"] forKey:@"game_id"];
        
        [APIsList sendJasonDATa:dict url:getOfflineGameDetails Selector:@selector(callBackGetOfflineGameDetails:) WithCallBackObject:self];
    }
    
}


-(void)callBackGetOfflineGameDetails:(NSDictionary*)dictRes
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([dictRes isKindOfClass:[NSDictionary class]]) {
        
        if ([[dictRes objectForKey:@"status"]integerValue]==1) {
            ObjApp_Delegate.objGameOffline=(OfflineGameVC*)[ObjApp_Delegate getGameViewControllerObject:NO];
            ObjApp_Delegate.objGameOffline.dictMain=dictRes;
            [ObjApp_Delegate changeRootVieController:ObjApp_Delegate.objGameOffline];
        }
    }
    else
    {
        [App_Delegate showAlertView:@"Error!" strMessage:[dictRes objectForKey:@"message"]];
    }
}


-(IBAction)btnBackClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
