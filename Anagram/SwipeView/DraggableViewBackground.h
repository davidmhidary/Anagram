//
//  DraggableViewBackground.h
//  testing swiping
//
//  Created by Ridmal Choudhary on 9/21/15.
//  Copyright (c) 2015 SquareBits Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"
#import "RemoteImageView.h"

@interface DraggableViewBackground : UIView <DraggableViewDelegate>

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)noDataLeft;

@property (retain,nonatomic) NSArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic) NSMutableArray* allCards; //%%% the labels the cards
-(void)loadCards;


@end
