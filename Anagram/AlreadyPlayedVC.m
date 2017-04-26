//
//  AlreadyPlayedVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 19/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "AlreadyPlayedVC.h"
#import "PlayerTypeVC.h"
#import "InviteFreindsForNativeUserVC.h"

#import "HomeVC.h"
#import "TutorialVC.h"

@interface AlreadyPlayedVC ()

@end

@implementation AlreadyPlayedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];

    // Do any additional setup after loading the view from its nib.
}



//go to home vc after clicking on YES or NO
-(IBAction)gotHome:(id)sender
{
      HomeVC *hVC=[[HomeVC alloc]init];
      [self.navigationController pushViewController:hVC animated:YES];
}


//on clicking button no go to Tutorial Screen

-(IBAction)showTutorial:(id)sender
{
    TutorialVC *hVC=[[TutorialVC alloc]init];
    [self.navigationController pushViewController:hVC animated:YES];
}

-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
