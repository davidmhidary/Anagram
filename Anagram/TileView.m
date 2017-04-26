//
//  TileView.m
//  Anagram
//
//  Created by Ashok Choudhary on 06/05/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "TileView.h"

@implementation TileView



+ (TileView*)initWithFrame:(CGRect)frame
{
    TileView *CustomAlertView = [[[NSBundle mainBundle] loadNibNamed:@"TileView" owner:nil options:nil] lastObject];
     CustomAlertView.frame=frame;
    if ([CustomAlertView isKindOfClass:[TileView class]])
        return CustomAlertView;
    else
        return nil;
}

@end
