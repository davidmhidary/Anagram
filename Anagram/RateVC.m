//
//  RateVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 30/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "RateVC.h"
@interface RateVC ()

@end

@implementation RateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rate=0;
    [vuStarView displayRating:rate]; //Set blank rate

    [vuStarView setImagesDeselected:@"star_unselected" partlySelected:nil fullSelected:@"star_selected" andDelegate:self];

    // Do any additional setup after loading the view from its nib.
}


-(void)ratingChanged:(float)newRating
{
    
    NSLog(@"%f",newRating);
    
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
