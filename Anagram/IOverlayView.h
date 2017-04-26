//
//  OverlayView.h
//  Ragsbox
//
//  Created by Ashok Choudhary on 09/12/15.
//  Copyright © 2015 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IovelayDelegates <NSObject>

@optional
-(void)didAllSlidesFinished:(UIView*)view;

@end
@interface IOverlayView : UIView
{
    
    int count;
}

@property(nonatomic,strong)NSMutableArray *arrImages;
@property(nonatomic,strong)IBOutlet UIImageView *imgOverlay;
@property(nonatomic,weak)id<IovelayDelegates>delegate;

+ (IOverlayView*)ViewWithFrame:(CGRect)frame;
@end
