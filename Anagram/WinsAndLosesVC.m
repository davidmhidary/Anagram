//
//  WinsAndLosesVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 30/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "WinsAndLosesVC.h"
#import "WinsAndLosesCell.h"


@interface WinsAndLosesVC ()

@end

@implementation WinsAndLosesVC

- (void)viewDidLoad {
    [super viewDidLoad];


    [self callAPIgetPendingGamesList];
}


-(void)callAPIgetPendingGamesList
{
//    NSString *strUrl=getPendingGamesList;
    NSString *strUrl=    getusersGamesDetail;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:App_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:@"ONLINE" forKey:@"mode"];

//    [APIsList sendJasonDATa:dict url:strUrl Selector:@selector(callBackPendingList:) WithCallBackObject:self];
    
    [APIsList callPostAsyncAPIUrl:strUrl withParameter:dict CallBackMethod:@selector(callBackPendingList:) toTarget:self showHUD:YES];
}

-(void)callBackPendingList:(NSMutableDictionary*)dicRes
{
    if ([[dicRes objectForKey:@"status"]integerValue]==1) {
      //  arrPendingGames=[dicRes objectForKey:@"game"];
        
          arrPendingGames=[dicRes objectForKey:@"usergamedetail"];
        
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
    static NSString *Identifier = @"WinsAndLosesCell";
    
    WinsAndLosesCell *cell = (WinsAndLosesCell*)[tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if(cell==nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"WinsAndLosesCell" owner:nil options:nil];
        cell=[topLevelObjects firstObject];
    }
    
    /*
    NSDictionary *dict=[arrPendingGames objectAtIndex:indexPath.row];
    cell.lblPlayerName.text=[dict objectForKey:@"username"];
    cell.lblScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"user_score"]];
    cell.lblOponentScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"opponent_score"]];

    NSString *strTurnId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"turn_user"]];
    
    if ([strTurnId isEqualToString:ObjApp_Delegate.currentUser.userID]) {
        cell.imgOpponent.hidden=YES;
        cell.imgUserTurn.hidden=NO;
    }
    else
    {
        cell.imgOpponent.hidden=NO;
        cell.imgUserTurn.hidden=YES;
        
    }*/
    
    
    NSDictionary *dict=[arrPendingGames objectAtIndex:indexPath.row];

    NSString *strTurnId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"winner_id"]];
    NSString *strUserId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"user_id"]];
    if ([strUserId isEqualToString:ObjApp_Delegate.currentUser.userID])
    {
        cell.lblPlayerName.text=[dict objectForKey:@"opponent_username"];
        cell.lblScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"user_score"]];
        cell.lblOponentScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"opponent_score"]];
    }
    else
    {
        cell.lblPlayerName.text=[dict objectForKey:@"username"];
        cell.lblScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"opponent_score"]];
        cell.lblOponentScore.text=[NSString stringWithFormat:@"Score:%@",[dict objectForKey:@"user_score"]];
    }
    
    

    
    cell.lblDate.text=[dict objectForKey:@"date"];
    if ([strTurnId isEqualToString:ObjApp_Delegate.currentUser.userID]) {
        cell.imgOpponent.hidden=YES;
//        cell.imgUserTurn.hidden=NO;
        cell.imgUserTurn.hidden=YES;

    }
    else
    {
//        cell.imgOpponent.hidden=NO;
        cell.imgOpponent.hidden=YES;
        cell.imgUserTurn.hidden=YES;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  //  NSDictionary *dict=[arrPendingGames objectAtIndex:indexPath.row];
    
  //  [self getPendigGames_Details:dict];
    
}


-(void)getPendigGames_Details:(NSDictionary*)dictDetails
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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




-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





@end
