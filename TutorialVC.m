//
//  TutorialVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 21/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "TutorialVC.h"
#import "HomeVC.h"
@interface TutorialVC ()

@end

@implementation TutorialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    arrImages_tut=[[NSArray alloc]initWithObjects:@"tutorial_1",@"tutorial_2",@"tutorial_3",@"tutorial_4",@"tutorial_5", nil];
    
    [self setScrollview];
    
    
    UISwipeGestureRecognizer *swap=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeViewCalled:)];
    swap.direction=UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swap];
    [scrl.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];

}


-(void)swipeViewCalled:(UISwipeGestureRecognizer*)swipe
{
    HomeVC *hvc=[[HomeVC alloc]init];
    [self.navigationController pushViewController:hvc animated:YES];
}



-(void)setScrollview
{
    
    [scrl setContentSize:CGSizeMake(scrl.frame.size.width*arrImages_tut.count, scrl.frame.size.height)];
    for (int i=0; i<arrImages_tut.count; i++)
    {
    
        UIImageView *imgV=[[UIImageView alloc]initWithFrame:CGRectMake(i*scrl.frame.size.width, 0, scrl.frame.size.width, scrl.frame.size.height)];
        imgV.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",[arrImages_tut objectAtIndex:i]]];
        [scrl addSubview:imgV];
        
    }
    
}


-(IBAction)btnBackClicked:(id)sender
{
    HomeVC *hvc=[[HomeVC alloc]init];
    [self.navigationController pushViewController:hvc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
