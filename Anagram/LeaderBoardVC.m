//
//  LeaderBoardVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "LeaderBoardVC.h"
#import "LeaderBoardCell.h"
#import "SVPullToRefresh.h"

@interface LeaderBoardVC ()

@end

@implementation LeaderBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    page=1;
    
    arrUsersData=[[NSMutableArray alloc]init];
    
    
    
//    __weak LeaderBoardVC *weakSelf = self;
//    
//    [tblData addInfiniteScrollingWithActionHandler:^{
//        [weakSelf callApi:1];
//    }];
    
    
    [self callApi:2];
    
    // Do any additional setup after loading the view from its nib.
}


-(IBAction)btnFbclicked:(id)sender
{
    [arrUsersData removeAllObjects];
    [tblData reloadData];

    page=1;
    btnFb.selected=YES;
    btnWorld.selected=NO;
    [self callApi:1];

}

-(IBAction)btnWorld:(id)sender
{
    [arrUsersData removeAllObjects];
    [tblData reloadData];
    page=1;
    btnFb.selected=NO;
    btnWorld.selected=YES;
    [self callApi:2];
}


-(void)callApi:(int)Value
{
    if (Value==1) {
        
        lblHighScores.text=@"FRIENDS HIGH SCORES";
        [self callLeaderBoardApi:@"SOCIAL"];
    }
    else
    {
        lblHighScores.text=@"WORLDS HIGH SCORES";
        [self callLeaderBoardApi:@"NATIVE"];
    }
}


-(void)callLeaderBoardApi:(NSString*)type
{
 
     NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dict setObject:type forKey:@"type"];
    
    [APIsList callPostAsyncAPIUrl:leaderboardapi withParameter:dict CallBackMethod:@selector(callBackLeaderBoard:) toTarget:self showHUD:YES];
    
}

-(void)callBackLeaderBoard:(NSDictionary*)dictRes
{
    [tblData.infiniteScrollingView stopAnimating];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([dictRes isKindOfClass:[NSDictionary class]]) {
        if ([[dictRes objectForKey:@"status"]integerValue]==1)
        {
            NSArray *arr=[dictRes objectForKey:@"leaderboard"];
            
            for (int i=0; i<arr.count; i++) {
                
                NSDictionary *dict=[arr objectAtIndex:i];
                [arrUsersData addObject:dict];
            }
            if (arr.count>0) {
                page=page+1;
            }
            lblName.text=ObjApp_Delegate.currentUser.userName;
            lblScore.text=[dictRes objectForKey:@"user_score"];
            [tblData reloadData];
        }
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return arrUsersData.count;

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"LeaderBoardCell";
    
    LeaderBoardCell *cell = (LeaderBoardCell*)[tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if(cell==nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"LeaderBoardCell" owner:nil options:nil];
        
        
        cell=[topLevelObjects firstObject];
    }
    
    NSDictionary *dict=[arrUsersData objectAtIndex:indexPath.row];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        cell.lblName.text=  [[dict objectForKey:@"username"]capitalizedString];
        cell.lblScore.text= [dict objectForKey:@"score"];
    }
    
    return cell;
}

-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)btnToggleFriendsClicked:(UIButton*)sender
{
    if (sender.selected) {
        sender.selected=NO;
        [self btnFbclicked:nil];
    }
    else
    {
        sender.selected=YES;
        [self btnWorld:nil];
    }
}

-(IBAction)shareOnFB
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    content.contentDescription=[NSString stringWithFormat:@"I beat my opponent in anagrams.io by 10 points!"];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.shareContent = content;
    
    dialog.mode=FBSDKShareDialogModeFeedWeb;
    dialog.delegate=self;
    if (![dialog canShow]) {
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    
    [dialog show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    
    [ObjApp_Delegate showAlertView:@"" strMessage:@"Message shared on facebook successfully"];
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
