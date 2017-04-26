//
//  BeginVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 16/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "BeginVC.h"
#import "LoginSignUpVC.h"

@interface BeginVC ()

@end

@implementation BeginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(IBAction)btnBeginClicked:(id)sender
{
     LoginSignUpVC *lVC=[[LoginSignUpVC alloc]init];
    [self.navigationController pushViewController:lVC animated:YES];
}

- (void)didReceiveMemoryWarning
{

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
