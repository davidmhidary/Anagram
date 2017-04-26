//
//  InstructionsVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//
#import "TileView.h"
#import "BaseViewForTiles.h"

#import <UIKit/UIKit.h>
#import "IOverlayView.h"
#import "CHCircleGaugeView.h"
@interface InstructionsVC : UIViewController<UIScrollViewDelegate,IovelayDelegates>

{
    NSArray *arrImages_tut;
    IBOutlet UIScrollView *scrl;
    IBOutlet UIPageControl *pageCntrl;
    IBOutlet UIButton *btn6;
    NSInteger page;
    IBOutlet CHCircleGaugeView *progressCircle;
    IBOutlet UIButton *btnOwner,*btnOpp,*btnStack;
    NSMutableArray *arrRandomFrames,*arrStealedCharsMainArray,*arrRevealedChars;
    int counter;
    
    IBOutlet UIImageView *btnHighHand;
    IBOutlet UIView *vwAns;
    
    IBOutlet UIButton *btnSubmit;
    
    IBOutlet UIScrollView *scrlUser2,*lblScrlUSER1;
    
    BOOL isNormalSteal,isStandSteal,isWrongMove;
    
    TileView *refTileSteal,*refTileSteal2,*refTileWrong;
    
    IBOutlet UILabel *lblDemoText;
    
    IBOutlet UILabel *lblHeader;
    
    IBOutlet UIImageView *redCross;
    
    IBOutlet UILabel *lblOpS,*lblOwnerS;
    
    NSMutableArray *arrAnswers;
    
    int stealNumber;
    int isIllegalNumber;
}

@property BOOL isLiveVersion;
@end
