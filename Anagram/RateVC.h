//
//  RateVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 30/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface RateVC : UIViewController<RatingViewDelegate>
{
    IBOutlet RatingView *vuStarView;
    int rate;
}
@end
