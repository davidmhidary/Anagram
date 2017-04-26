//
//  WordOfTheDayVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "WordOfTheDayVC.h"

@interface WordOfTheDayVC ()

@end

@implementation WordOfTheDayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
  [self callBackWordOfDay];
    // Do any additional setup after loading the view from its nib.
}


-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




-(void)callBackWordOfDay
{
    
     UIView *viewH=[[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWOD.frame.size.width, viewWOD.frame.size.height)];
    viewH.backgroundColor=[UIColor clearColor];
    
    NSString *strWord=@"Hand";

    
    if (self.strWordOfDay.length>0) {
        
        strWord=self.strWordOfDay;
    }
    
    lblWOD.text=[strWord uppercaseString];
    
    NSInteger point=(strWord.length-2)*2;
    lblWordPoints.text=[NSString stringWithFormat:@"%lu points",(long)point];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
