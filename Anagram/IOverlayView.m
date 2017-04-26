//
//  OverlayView.m
//  Ragsbox
//
//  Created by Ashok Choudhary on 09/12/15.
//  Copyright © 2015 squarebits. All rights reserved.
//

#import "IOverlayView.h"

@implementation IOverlayView

+ (IOverlayView*)ViewWithFrame:(CGRect)frame
{
    IOverlayView *overLayView = [[[NSBundle mainBundle] loadNibNamed:@"IOverlayView" owner:nil options:nil] lastObject];
    

    overLayView.frame=frame;
      // make sure customView is not nil or the wrong class!
    if ([overLayView isKindOfClass:[IOverlayView class]])
        return overLayView;
    else
        return nil;
}



-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    count++;

    if (count==self.arrImages.count)
    {
        if ([self.delegate respondsToSelector:@selector(didAllSlidesFinished:)]) {
            [self.delegate didAllSlidesFinished:self];
        }
        return;
    }

    NSLog(@"image name %@",[self.arrImages objectAtIndex:count]);
    
//    self.imgOverlay.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@",[self.arrImages objectAtIndex:count]]];
    
    [self changeImageWithAnimation];

}


-(void)changeImageWithAnimation
{
   
    
     [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^
     
     {
          self.imgOverlay.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@",[self.arrImages objectAtIndex:count]]];
         
     }
                     completion:Nil];

}




@end
