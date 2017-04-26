//
//  OverlayView.h
//  testing swiping
//
//  Created by Ridmal Choudhary on 9/23/15.
//  Copyright (c) 2015 SquareBits Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , GGOverlayViewMode) {
    GGOverlayViewModeLeft,
    GGOverlayViewModeRight
};

@interface OverlayView : UIView
@property (nonatomic) GGOverlayViewMode mode;
@property (nonatomic, strong) UIImageView *imageView;

@end
