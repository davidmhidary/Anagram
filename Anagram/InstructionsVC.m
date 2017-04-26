//
//  InstructionsVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "InstructionsVC.h"

#define labelwidthAndheight  30
#define xPosition  80
#define yPosition  220

@interface InstructionsVC ()

@end

@implementation InstructionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    /*
     btn6.hidden=YES;
     arrImages_tut=[[NSArray alloc]initWithObjects:@"tutorial_page9_overlay.png",@"tutorial_page10_overlay.png",@"tutorial_page11_overlay.png",@"tutorial_page12_overlay.png",@"tutorial_page13_overlay.png",@"tutorial_page14_overlay.png",@"tutorial_page15_overlay.png",@"tutorial_page16_overlay.png",@"tutorial_page17_overlay.png",@"tutorial_page18_overlay.png",@"tutorial_page19_overlay.png",@"tutorial_page20_overlay.png",@"tutorial_page21_overlay.png",@"tutorial_page22_overlay.png",@"tutorial_page23_overlay.png",@"tutorial_page24_overlay.png",@"tutorial_page25_overlay.png",nil];
     
     [self setScrollview];
     */
    
    
//    UISwipeGestureRecognizer *swap=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeViewCalled:)];
//    swap.direction=UISwipeGestureRecognizerDirectionDown;
//    [self.view addGestureRecognizer:swap];
//    [scrl.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    // [self ShowOverlayTutorial];
    
    
    
    progressCircle.state = CHCircleGaugeViewStateScore;
    progressCircle.trackWidth = 1;
    progressCircle.gaugeWidth = 3;
    progressCircle.gaugeStyle = CHCircleGaugeStyleOutside;
    progressCircle.trackTintColor = [UIColor clearColor];
    progressCircle.gaugeTintColor = [UIColor greenColor];
    progressCircle.noDataString=@"";
    progressCircle.unitsString=@"%";
    progressCircle.textColor=[UIColor clearColor];
    [progressCircle setValue:1.0 animated:YES];
    
    [self addFramesinArrayOfAllPool];
    
    
    btnHighHand.alpha=0;
    btnStack.userInteractionEnabled=NO;
    [UIView animateWithDuration:3.0 animations:^{
        btnHighHand.hidden=NO;
        btnHighHand.alpha=1;
        btnStack.userInteractionEnabled=YES;
        
        
    }];
    
    NSMutableArray *arrAnimationI=[[NSMutableArray alloc]init];
    for (int i=1; i<41; i++) {
        
        NSString *str=[NSString stringWithFormat:@"hand-animation00%d.png", i];
        [arrAnimationI addObject:(id)[UIImage imageNamed:str]];
    }
    
    [btnHighHand setAnimationImages:arrAnimationI];
    
    [btnHighHand startAnimating];
    
    btnSubmit.userInteractionEnabled=NO;
    
    
    if ([[UIScreen mainScreen]bounds].size.height<500) {
        
        btnSubmit.hidden=YES;
        btnStack.userInteractionEnabled=NO;
        
    }
    else
    {
        btnSubmit.hidden=NO;
        btnStack.userInteractionEnabled=YES;

    }
    
}




-(void)addFramesinArrayOfAllPool
{
    
    
    arrRandomFrames=[[NSMutableArray alloc]init];
    arrStealedCharsMainArray=[[NSMutableArray alloc]init];
    arrRevealedChars=[[NSMutableArray alloc]init];
    
    arrAnswers=[[NSMutableArray alloc]init];
    
    for (int i=0; i<7; i++)
    {
        for (int j=0; j<3; j++)
        {
            CGRect frame=CGRectMake(0, 0, labelwidthAndheight, labelwidthAndheight);
            CGFloat xP=xPosition+((labelwidthAndheight+2)*i);
            CGFloat yP=yPosition+((labelwidthAndheight+2)*j);
            frame.origin.x=xP;
            frame.origin.y=yP;
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
            [dict setObject:@"0" forKey:@"isUsed"];
            [arrRandomFrames addObject:dict];
        }
    }
}




-(IBAction)btnHighLightedHandTapped:(id)sender
{
    btnSubmit.userInteractionEnabled=NO;
    counter=counter+1;
    
    switch (counter)
    {
        case 1:
        {
            [self addTilesInPoolForCurrentUser:@"A"];
            btnOwner.selected=NO;
            btnOpp.selected=YES;
            btnHighHand.alpha=1;
            btnStack.userInteractionEnabled=NO;
            [UIView animateWithDuration:0.5 animations:^{
                btnHighHand.hidden=YES;
                btnHighHand.alpha=0;
            }];
            [self performSelector:@selector(addTilesToanotherUser:) withObject:@"N" afterDelay:1.5];
            [self showFooterLabelAnimation:@"When your score turns green, tap the stack to flip a tile"];
            
            lblHeader.text=@"Flip a tile";
        }
            break;
        case 2:
        {
            
            btnStack.userInteractionEnabled=NO;
            [self addTilesInPoolForCurrentUser:@"D"];
            
            [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:1.0];
            [self showFooterLabelAnimation:@"To claim a word, tap the tiles in the order it is spelled."];
            
            lblHeader.text=@"Create a Word";
            
            
        }
            break;
        case 3:
        {
            btnStack.userInteractionEnabled=NO;
            
            isNormalSteal=YES;
            [self addTilesInPoolForCurrentUser:@"B"];
            [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:1.0];
            lblHeader.text=@"Adding Letters";
        }
            break;
        case 4:
        {
            btnStack.userInteractionEnabled=NO;
            isStandSteal=YES;
            isNormalSteal=NO;
            
            btnOwner.selected=NO;
            btnOpp.selected=YES;

           [self addTilesInPoolForCurrentUser:@"T"];
           [UIView animateWithDuration:0.5 animations:^{
                btnHighHand.hidden=YES;
                btnHighHand.alpha=0;
            }];
            [self performSelector:@selector(addTilesToanotherUser:) withObject:@"O" afterDelay:1.5];
            lblHeader.text=@"Steals";
         }
            break;
        case 5:
        {
            btnStack.userInteractionEnabled=NO;
            isStandSteal=YES;
            isNormalSteal=NO;
            
            btnOwner.selected=NO;
            btnOpp.selected=YES;

            [self addTilesInPoolForCurrentUser:@"P"];
            [UIView animateWithDuration:0.5 animations:^{
                 btnHighHand.alpha=0;
            } completion:^(BOOL finished) {
                
                for (UIView *view in vwAns.subviews)
                {
                    [view removeFromSuperview];
                }
                NSArray*    arrayChars=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
                [self performSelector:@selector(removeALlviewandStartStealLogicFromOpponent:) withObject:arrayChars afterDelay:0.5];
                lblScrlUSER1.userInteractionEnabled=NO;
                [arrStealedCharsMainArray removeAllObjects];
                stealNumber=2;
                
                lblOwnerS.text=@"2";
                lblOpS.text=@"1";
                
                btnOwner.selected=YES;
                btnOpp.selected=NO;
                btnStack.userInteractionEnabled=YES;
                btnHighHand.hidden=NO;
                btnHighHand.alpha=1;
                for (TileView *tt in arrRevealedChars) {
                    [tt removeFromSuperview];
                }
              
                [arrRevealedChars removeAllObjects];

            }];
           // [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:1.0];
        }
            break;
        case 6:
        {
            btnStack.userInteractionEnabled=NO;
            isStandSteal=YES;
            isNormalSteal=NO;
            isWrongMove=NO;
            
            btnOwner.selected=YES;
            btnOpp.selected=NO;

            
            [self addTilesInPoolForCurrentUser:@"S"];
             [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:1.0];
         }
            break;
        case 7:
        {
            btnStack.userInteractionEnabled=NO;
            isStandSteal=NO;
            isNormalSteal=NO;
            isWrongMove=YES;
            btnOwner.selected=NO;
            btnOpp.selected=YES;

            [self addTilesInPoolForCurrentUser:@"T"];
            [UIView animateWithDuration:0.5 animations:^{
                btnHighHand.hidden=YES;
                btnHighHand.alpha=0;
            }];
            [self performSelector:@selector(addTilesToanotherUser:) withObject:@"O" afterDelay:1.5];
            lblHeader.text=@"Illegal Moves";
        }
            break;
        case 8:
        {
            btnStack.userInteractionEnabled=NO;
             isStandSteal=NO;
            isNormalSteal=NO;
            isWrongMove=YES;
            btnOwner.selected=NO;
            btnOpp.selected=YES;

            [self addTilesInPoolForCurrentUser:@"P"];
            [UIView animateWithDuration:0.5 animations:^{
                btnHighHand.alpha=0;
            } completion:^(BOOL finished) {
                
                for (UIView *view in vwAns.subviews)
                {
                    [view removeFromSuperview];
                }
                NSArray*    arrayCharss=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
                [self performSelector:@selector(arrangeUserScrollviewForWrongMove:) withObject:arrayCharss afterDelay:0.5];
                isIllegalNumber=2;
                btnStack.userInteractionEnabled=YES;
                btnOwner.selected=YES;
                btnOpp.selected=NO;
                btnHighHand.hidden=NO;
                btnHighHand.alpha=1;
                lblOpS.text=@"1";
                
                for (TileView *tt in arrRevealedChars) {
                    [tt removeFromSuperview];
                }
                
                [arrRevealedChars removeAllObjects];
                [arrStealedCharsMainArray removeAllObjects];

            }];
         //   [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:1.0];
        }
            break;
        case 9:
        {
            btnStack.userInteractionEnabled=NO;
            isStandSteal=NO;
            isNormalSteal=NO;
            isWrongMove=YES;
            
            btnOwner.selected=YES;
            btnOpp.selected=NO;

            [self addTilesInPoolForCurrentUser:@"S"];
            
            lblScrlUSER1.userInteractionEnabled=YES;
            CGPoint p=[lblScrlUSER1 convertPoint:refTileSteal2.center toView:self.view];
            p.x=20;
            btnHighHand.center=p;
            [self.view bringSubviewToFront:btnHighHand];

        }
            break;

            
        default:
            break;
    }
}


-(void)showAnimationWithDelay
{
    TileView *t=[arrRevealedChars firstObject];
    btnHighHand.center=t.center;
    btnHighHand.alpha=0;
    [UIView animateWithDuration:1.0 animations:^{
        t.userInteractionEnabled=YES;
        btnHighHand.alpha=1;
        [self.view bringSubviewToFront:btnHighHand];
        
    }];
    
}

-(void)showFooterLabelAnimation:(NSString*)strText
{
    
    lblDemoText.alpha=0;
    lblDemoText.text=strText;
    
    //    [UIView animateWithDuration:2.0 animations:^{
    //
    //        lblDemoText.alpha=1.0;
    //
    //    }];
    
    [UIView animateWithDuration:2.0
                          delay:0.5
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         [lblDemoText setAlpha:1.0];
     }
                     completion:^(BOOL finished)
     {
     }];
    
    
}



-(void)addTilesToanotherUser:(NSString*)strText
{
    btnOwner.selected=YES;
    btnOpp.selected=NO;
    
    btnHighHand.alpha=0;
    
    [UIView animateWithDuration:0.5 animations:^{
        btnHighHand.alpha=1;
        btnHighHand.hidden=NO;
        btnStack.userInteractionEnabled=YES;
        
    }];
    
    [self addTilesInPoolForOpponentTapped:strText];
}


-(void)addTilesInPoolForCurrentUser:(NSString*)text
{
    
    
    if (arrRandomFrames.count==0)
    {
        
        return;
    }
    
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    
    TileView *view=[TileView initWithFrame:CGRectMake(0, btnStack.frame.origin.y,labelwidthAndheight, labelwidthAndheight)];
    
    view.isTilesBelongsToScrollView=NO;
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.3f;
    view.layer.shadowPath = shadowPath3.CGPath;
    
    
    
    
    
    
    
    CGRect rectNewView=view.frame;
    
    rectNewView=[self getRandomFrame:rectNewView Tv:view];
    
    if (CGRectEqualToRect(rectNewView, CGRectZero)) {
        // do some stuff
        return;
    }
    
    
    view.userInteractionEnabled=NO;
    
    
    NSString *charV=text;
    view.lblT.text=[charV uppercaseString];
    
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    [view clipsToBounds];
    
    
    
    
    [UIView animateWithDuration:0.3 animations:^
     {
         view.frame=rectNewView;
         
     }completion:^(BOOL finished) {
         
         [arrRevealedChars addObject:view];
         
     }];
    
    
    
}


-(void)addTilesInPoolForOpponentTapped:(NSString*)text
{
    
    if (arrRandomFrames.count==0)
    {
        
        return;
    }
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    
    TileView *view=[TileView initWithFrame:CGRectMake(130, 0,labelwidthAndheight, labelwidthAndheight)];
    
    
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.3f;
    view.layer.shadowPath = shadowPath3.CGPath;
    
    
    CGRect rectNewView=view.frame;
    rectNewView=[self getRandomFrame:rectNewView Tv:view];
    if (CGRectEqualToRect(rectNewView, CGRectZero)) {
        return;
    }
    NSString *charV=text;
    view.lblT.text=[charV uppercaseString];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    [view clipsToBounds];
    
    view.userInteractionEnabled=NO;
    
    
    [UIView animateWithDuration:0.3 animations:^
     {
         view.frame=rectNewView;
         
     }completion:^(BOOL finished) {
         
         [arrRevealedChars addObject:view];
         
     }];
}



-(CGRect)getRandomFrame:(CGRect)oldFrame  Tv:(TileView*)tilView
{
    CGRect newframe=oldFrame;
    newframe=[self getFreeSlotFrame:tilView];
    return newframe;
}


-(CGRect)getFreeSlotFrame:(TileView*)tile
{
    CGRect rect=CGRectZero;
    NSMutableArray *arrFreeFrameArray=[[NSMutableArray alloc]init];
    for (int i=0; i<arrRandomFrames.count; i++)
    {
        NSMutableDictionary *dict=[arrRandomFrames objectAtIndex:i];
        if ([[dict objectForKey:@"isUsed"] isEqualToString:@"0"])
        {
            [arrFreeFrameArray addObject:dict];
        }
    }
    
    if (arrFreeFrameArray.count>0)
    {
        NSInteger randomNumber =    arc4random() % [arrFreeFrameArray count];
        NSMutableDictionary *dictF=[arrFreeFrameArray objectAtIndex:randomNumber];
        [dictF setObject:@"1" forKey:@"isUsed"];
        rect =[[dictF objectForKey:@"frame"] CGRectValue];
        tile.dictTileFrame=dictF;
    }
    
    return rect;
}




-(void)handleTap:(UITapGestureRecognizer*)tap
{
    
    TileView *tV=(TileView*)tap.view;
    
    [arrStealedCharsMainArray addObject:tV];
    [self fillTheTilesInUserBoxAfterSelected];
    
    
    if (isNormalSteal)
    {
        
        if (arrRevealedChars.count>0)
        {
            
            scrlUser2.userInteractionEnabled=YES;
            CGPoint p=[scrlUser2 convertPoint:refTileSteal.center toView:self.view];
            btnHighHand.center=p;

            btnHighHand.alpha=0.0;
            [UIView animateWithDuration:1.0 animations:^{
                btnHighHand.alpha=1.0;

            }];

            [self.view bringSubviewToFront:btnHighHand];
            
            
        }
        else
        {
            btnSubmit.userInteractionEnabled=YES;

            btnHighHand.center=btnSubmit.center;
            btnHighHand.alpha=0.0;
            [UIView animateWithDuration:1.0 animations:^{
                
                btnHighHand.alpha=1.0;
                [self.view bringSubviewToFront:btnHighHand];
            }];
            
        }
        
    }
    else if (isStandSteal)
    {
        
        if (stealNumber==2) {
         
              lblScrlUSER1.userInteractionEnabled=YES;
                     CGPoint p=[lblScrlUSER1 convertPoint:refTileSteal2.center toView:self.view];
            btnHighHand.alpha=0.0;
            btnHighHand.center=p;

            [UIView animateWithDuration:1.0 animations:^{
                btnHighHand.alpha=1.0;
                
            }];

//            btnHighHand.center=p;
             [self.view bringSubviewToFront:btnHighHand];

        }
        else
        {
            [arrRevealedChars removeObject:tV];
            
            if (arrRevealedChars.count>0)
            {
                TileView *new=[arrRevealedChars firstObject];
                btnHighHand.center=new.center;
                btnHighHand.alpha=0.0;
                [UIView animateWithDuration:1.0 animations:^{
                    btnHighHand.alpha=1.0;
                    
                }];

                new.userInteractionEnabled=YES;
                [self.view bringSubviewToFront:btnHighHand];
                 stealNumber=1;
             }
            else
            {
                btnSubmit.userInteractionEnabled=YES;

                btnHighHand.center=btnSubmit.center;

                btnHighHand.alpha=0.0;
                [UIView animateWithDuration:1.0 animations:^{
                    btnHighHand.alpha=1.0;
                    
                }];

                [self.view bringSubviewToFront:btnHighHand];
             }

        }
     }
    else if (isWrongMove)
    {
        
        if (isIllegalNumber==2)
        {
            btnSubmit.userInteractionEnabled=YES;

            CGPoint p=btnSubmit.center;
            btnHighHand.alpha=0.0;
            btnHighHand.center=p;

            [UIView animateWithDuration:1.0 animations:^{
                btnHighHand.alpha=1.0;
                
            }];
            [self.view bringSubviewToFront:btnHighHand];

        }
        else
        {
            [arrRevealedChars removeObject:tV];
            
            if (arrRevealedChars.count>0)
            {
                TileView *new=[arrRevealedChars firstObject];
                btnHighHand.center=new.center;
                btnHighHand.alpha=0.0;
                [UIView animateWithDuration:1.0 animations:^{
                    btnHighHand.alpha=1.0;
                }];
                new.userInteractionEnabled=YES;
                [self.view bringSubviewToFront:btnHighHand];
                isIllegalNumber=1;
            }
            else
            {
                btnSubmit.userInteractionEnabled=YES;

                btnHighHand.center=btnSubmit.center;
                btnHighHand.alpha=0.0;

                CGPoint p=btnSubmit.center;
                btnHighHand.center=p;

                [UIView animateWithDuration:1.0 animations:^{
                    btnHighHand.alpha=1.0;
                }];

                [self.view bringSubviewToFront:btnHighHand];
            }

        }
        
    }
    else
    {
        
        [arrRevealedChars removeObject:tV];
        
        if (arrRevealedChars.count>0)
        {
            TileView *new=[arrRevealedChars firstObject];
            btnHighHand.center=new.center;

            btnHighHand.alpha=0.0;
            [UIView animateWithDuration:1.0 animations:^{
                btnHighHand.alpha=1.0;

            }];
            //btnHighHand.center=new.center;
            new.userInteractionEnabled=YES;
            [self.view bringSubviewToFront:btnHighHand];
            
        }
        else
        {
            btnSubmit.userInteractionEnabled=YES;

            btnHighHand.center=btnSubmit.center;
             btnHighHand.alpha=0.0;
            [UIView animateWithDuration:1.0 animations:^{
                btnHighHand.alpha=1.0;

            }];
            [self.view bringSubviewToFront:btnHighHand];
            
            
        }
        
    }
}

-(void)fillTheTilesInUserBoxAfterSelected
{
    
    // if there is any charachters available in BOX then remove it before adding new one
    for (TileView *tV in vwAns.subviews) {
        
        if ([tV isKindOfClass:[TileView class]]) {
            [tV removeFromSuperview];
        }
    }
    
    
    
    for (int i=0; i<arrStealedCharsMainArray.count; i++) {
        
        TileView *t=[arrStealedCharsMainArray objectAtIndex:i];
        t.frame=CGRectMake(i*labelwidthAndheight, 0, labelwidthAndheight, labelwidthAndheight);
        t.userInteractionEnabled=NO;
        [vwAns addSubview:t];
        
    }
    
    
}


-(IBAction)btnSubMitClicked:(id)sender
{
    if (arrStealedCharsMainArray.count<3)
    {
        return;
    }
    
    
    
    
    if (isNormalSteal)
    {
       
        NSArray*arrayCharss=[NSArray arrayWithObjects:@"B",@"A",@"N",@"D", nil];

        [arrAnswers removeAllObjects];
        [arrAnswers addObject:arrayCharss];
        
        lblOwnerS.text=@"2";
        lblOpS.text=@"0";
        [self arrangeUserScrollviewAfterWordCompeltion];
        
        
        lblScrlUSER1.userInteractionEnabled=NO;
        
        [self showFooterLabelAnimation:@"Steal a word from your opponent by tapping ALL of their letters and at least 1 letter from the pool."];

    }
    else if (isStandSteal)
    {
        
        for (UIView *view in vwAns.subviews)
        {
            [view removeFromSuperview];
        }
        
        [self showFooterLabelAnimation:@"The new word can’t be a variation of the existing word - it must change the root meaning."];

        if (stealNumber==1)
        {
         
             NSArray*    arrayChars=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
            [self performSelector:@selector(removeALlviewandStartStealLogicFromOpponent:) withObject:arrayChars afterDelay:0.5];
            lblScrlUSER1.userInteractionEnabled=NO;
            [arrStealedCharsMainArray removeAllObjects];
            stealNumber=2;
            
            lblOwnerS.text=@"2";
            lblOpS.text=@"1";

            btnOwner.selected=YES;
            btnOpp.selected=NO;

        }
        else
        {
            NSArray*    arrayChars=[NSArray arrayWithObjects:@"S",@"T",@"O",@"P", nil];
            lblOwnerS.text=@"4";
            lblOpS.text=@"0";
            
            [arrAnswers addObject:arrayChars];
            [self arrangeUserScrollviewAfterWordCompeltion];
            
            
            isWrongMove=YES;
            isStandSteal=NO;
            
            [arrRevealedChars removeAllObjects];
            [arrStealedCharsMainArray removeAllObjects];

        }
        
        
        
    }
    else if (isWrongMove)
    {
        for (UIView *view in vwAns.subviews)
        {
            [view removeFromSuperview];
        }

        
        if (isIllegalNumber==1)
        {
        NSArray*    arrayCharss=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
        [self performSelector:@selector(arrangeUserScrollviewForWrongMove:) withObject:arrayCharss afterDelay:0.5];
        isIllegalNumber=2;
            
            [arrRevealedChars removeAllObjects];
            [arrStealedCharsMainArray removeAllObjects];

            btnOwner.selected=YES;
            btnOpp.selected=NO;

            
        }
        else
        {
            NSArray*    arrayCharss=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
            [self performSelector:@selector(arrangeUserScrollviewForWrongMove:) withObject:arrayCharss afterDelay:0.5];

            vwAns.hidden=YES;
            redCross.hidden=NO;
            [self performSelector:@selector(btnBackClicked:) withObject:nil afterDelay:4.0];

            [arrStealedCharsMainArray removeAllObjects];
            
            btnHighHand.hidden=YES;
            scrlUser2.userInteractionEnabled=NO;
            lblScrlUSER1.userInteractionEnabled=NO;
             lblOwnerS.text=@"4";
             lblOpS.text=@"1";

        }
        
    }
    else
    {
        NSArray* arrayChars=[NSArray arrayWithObjects:@"A",@"N",@"D", nil];
        [arrAnswers removeAllObjects];
        [arrAnswers addObject:arrayChars];
        lblOwnerS.text=@"1";
        lblOpS.text=@"0";
        [self arrangeUserScrollviewAfterWordCompeltion];
        scrlUser2.userInteractionEnabled=NO;
        [self showFooterLabelAnimation:@"You may take letters from the pool and add it to your own word."];

        
    }
    
    btnHighHand.alpha=0;
    btnHighHand.center=btnStack.center;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        btnHighHand.alpha=1;
        
        [self.view bringSubviewToFront:btnHighHand];
        
          if (isWrongMove)
        {
            lblHeader.text=@"Illegal Moves";
            
        }
        
    }];
    
    btnStack.userInteractionEnabled=YES;
    
    
}

-(void)arrangeUserScrollviewAfterWordCompeltion
{
    
    
    for (int k=0; k<arrAnswers.count; k++) {
        NSArray*arrayChars=[arrAnswers objectAtIndex:k];
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrayChars.count, labelwidthAndheight)];
        if (k==1)
        {
            view.frame= CGRectMake(130, 0, labelwidthAndheight*arrayChars.count, labelwidthAndheight);
        }
        for (int i=0; i<arrayChars.count; i++)
        {
            TileView *viewTile=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewTile.lblT.text= [arrayChars objectAtIndex:i];
            viewTile.userInteractionEnabled=NO;
            UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
            tapT.numberOfTapsRequired = 1;
            
            [viewTile addGestureRecognizer:tapT];
            
            [view addSubview:viewTile];
            
            if (i==0) {
                refTileSteal=viewTile;
                viewTile.userInteractionEnabled=YES;
            }
            if (arrStealedCharsMainArray.count>0) {
                TileView *remove=[arrStealedCharsMainArray objectAtIndex:i];
                [remove removeFromSuperview];
            }
            
        }
        
        
        [scrlUser2 addSubview:view];
        
    }
    
    
    scrlUser2.userInteractionEnabled=NO;
    
    [arrStealedCharsMainArray removeAllObjects];
    [arrRevealedChars removeAllObjects];
    
    
    
    
}


#pragma mark Steal Tutorial from own Words

-(void)tileSelectedForStealing:(UITapGestureRecognizer*)tap
{
    
    
    TileView *tView=(TileView*)tap.view;
    tView.lblT.textColor=[UIColor whiteColor];
    
    [arrStealedCharsMainArray addObject:tView];
    [self fillTheTilesInUserBoxAfterSelected];
    
    
    if (arrStealedCharsMainArray.count==4) {
        
        btnSubmit.userInteractionEnabled=YES;

        CGPoint p=btnSubmit.center;
        btnHighHand.center=p;
        btnHighHand.alpha=0.0;
        [UIView animateWithDuration:1.0 animations:^{
            btnHighHand.alpha=1.0;
            
            [self.view bringSubviewToFront:btnHighHand];
        }];
        
    }
    else
    {
        
        for (BaseViewForTiles *suv in scrlUser2.subviews) {
            if ([suv isKindOfClass:[BaseViewForTiles class]]) {
                for (TileView *t in suv.subviews) {
                    if ([t isKindOfClass:[TileView class]]) {
                        if (t.userInteractionEnabled==NO && t!=refTileSteal) {
                            t.userInteractionEnabled=YES;
                            break;
                        }
                    }
                }
            }
        }
        CGPoint p=btnHighHand.center;
        p.x=p.x+30;
        btnHighHand.center=p;
        [self.view bringSubviewToFront:btnHighHand];

    }
    
    tView.userInteractionEnabled=NO;
    
    
}


#pragma mark Steal Tutorial from own Steal opponent


-(void)removeALlviewandStartStealLogicFromOpponent:(NSArray *)arrayChars
{
    
    scrlUser2.userInteractionEnabled=NO;
    
    //    for (UIView *vi in scrlUser2.subviews) {
    //        [vi removeFromSuperview];
    //    }
    
    //     arrayChars=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
    
    for (UIView *vi in lblScrlUSER1.subviews) {
        [vi removeFromSuperview];
    }
    
    BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*3, labelwidthAndheight)];
    
    for (int i=0; i<arrayChars.count; i++)
    {
        TileView *viewTile=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
        viewTile.lblT.text= [arrayChars objectAtIndex:i];
        viewTile.userInteractionEnabled=NO;
        viewTile.isTilesBelongsToScrollView=YES;
        
        
        UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealingOpponentWord:)];
        tapT.numberOfTapsRequired = 1;
        
        [viewTile addGestureRecognizer:tapT];
        
        [view addSubview:viewTile];
        
        if (i==0) {
            refTileSteal2=viewTile;
            viewTile.userInteractionEnabled=YES;

        }
    }
    [lblScrlUSER1 addSubview:view];
    
 }

-(void)tileSelectedForStealingOpponentWord:(UITapGestureRecognizer*)tap
{
    
    
    
    TileView *tView=(TileView*)tap.view;
    tView.lblT.textColor=[UIColor whiteColor];
    
    [arrStealedCharsMainArray addObject:tView];
    [self fillTheTilesInUserBoxAfterSelected];
    
    
    if (arrStealedCharsMainArray.count==4) {
        
        btnSubmit.userInteractionEnabled=YES;

        CGPoint p=btnSubmit.center;
        btnHighHand.center=p;
        btnHighHand.alpha=0;
        [UIView animateWithDuration:1.0 animations:^{
            btnHighHand.alpha=1.0;
            [self.view bringSubviewToFront:btnHighHand];
        }];
    }
    else
    {
        
        for (BaseViewForTiles *suv in lblScrlUSER1.subviews) {
            if ([suv isKindOfClass:[BaseViewForTiles class]]) {
                for (TileView *t in suv.subviews) {
                    if ([t isKindOfClass:[TileView class]]) {
                        if (t.userInteractionEnabled==NO && t!=refTileSteal2) {
                            t.userInteractionEnabled=YES;
                            break;
                        }
                    }
                }
            }
        }

        
        CGPoint p=btnHighHand.center;
        p.x=p.x+30;
        btnHighHand.center=p;
        [self.view bringSubviewToFront:btnHighHand];
    }
}


#pragma mark WrongMOVES



-(void)tileSelectedForStealingWrongMoves:(UITapGestureRecognizer*)tap
{
    
    TileView *tView=(TileView*)tap.view;
    tView.lblT.textColor=[UIColor whiteColor];
    
    [arrStealedCharsMainArray addObject:tView];
    [self fillTheTilesInUserBoxAfterSelected];
    
    
    if (arrStealedCharsMainArray.count==3) {
        
        
        [self performSelector:@selector(showAnimationWithDelay) withObject:nil afterDelay:0.5];

        
    }
    else
    {
        for (BaseViewForTiles *suv in lblScrlUSER1.subviews) {
            if ([suv isKindOfClass:[BaseViewForTiles class]]) {
                for (TileView *t in suv.subviews) {
                    if ([t isKindOfClass:[TileView class]]) {
                        if (t.userInteractionEnabled==NO) {
                            t.userInteractionEnabled=YES;
                            break;
                        }
                    }
                }
            }
        }

        
        CGPoint p=btnHighHand.center;
        p.x=p.x+30;
        btnHighHand.center=p;
        [self.view bringSubviewToFront:btnHighHand];
    }
    
    
    
}



-(void)arrangeUserScrollviewForWrongMove:(NSArray*)arrayChars
{
    
    for (UIView *vi in lblScrlUSER1.subviews) {
        [vi removeFromSuperview];
    }
    
    //   scrlUser2.hidden=YES;
    
    arrayChars=[NSArray arrayWithObjects:@"T",@"O",@"P", nil];
    BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*3, labelwidthAndheight)];
    for (int i=0; i<arrayChars.count; i++)
    {
        TileView *viewTile=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
        viewTile.lblT.text= [arrayChars objectAtIndex:i];
        viewTile.userInteractionEnabled=NO;
        viewTile.isTilesBelongsToScrollView=YES;
        
        
        UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealingWrongMoves:)];
        tapT.numberOfTapsRequired = 1;
        
        [viewTile addGestureRecognizer:tapT];
        
        [view addSubview:viewTile];
        
        if (i==0) {
            refTileWrong=viewTile;
            viewTile.userInteractionEnabled=YES;

        }
    }
    [lblScrlUSER1 addSubview:view];
    

    lblScrlUSER1.userInteractionEnabled=NO;
}




#pragma mark oldd
-(void)swipeViewCalled:(UISwipeGestureRecognizer*)swipe
{
    
    CGRect frame =self.view.frame;
    
    frame.origin.y=frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        scrl.frame=frame;
        
    } completion:^(BOOL finished) {
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }];
    
}
-(void)setScrollview
{
    [scrl setContentSize:CGSizeMake(scrl.frame.size.width*arrImages_tut.count, scrl.frame.size.height)];
    for (int i=0; i<arrImages_tut.count; i++)
    {
        UIImageView *imgV=[[UIImageView alloc]initWithFrame:CGRectMake(i*scrl.frame.size.width,0, scrl.frame.size.width, scrl.frame.size.height)];
        imgV.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[arrImages_tut objectAtIndex:i]]];
        [scrl addSubview:imgV];
    }
}
-(IBAction)btnNextClicked:(UIButton*)sender
{
    
    if (page>=4) {
        page=-1;
    }
    page=page+1;
    [scrl setContentOffset:CGPointMake(scrl.frame.size.width*page, 0) animated:YES];
    
}
-(IBAction)btnBackClicked:(id)sender
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [self.navigationController popViewControllerAnimated:YES];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    page=scrollView.contentOffset.x/self.view.frame.size.width;
    [self setCircleSelectedOrNot:page];
    
}
-(void)setCircleSelectedOrNot:(NSInteger)tag
{
    UIButton *btn1=(UIButton *)[self.view viewWithTag:100];
    UIButton *btn2=(UIButton *)[self.view viewWithTag:101];
    UIButton *btn3=(UIButton *)[self.view viewWithTag:102];
    UIButton *btn4=(UIButton *)[self.view viewWithTag:103];
    UIButton *btn5=(UIButton *)[self.view viewWithTag:104];
    UIButton *btn11=(UIButton *)[self.view viewWithTag:105];
    
    UIButton *btnCurrent=(UIButton *)[self.view viewWithTag:tag+100];
    
    btn1.selected=NO;
    btn2.selected=NO;
    btn3.selected=NO;
    btn4.selected=NO;
    btn5.selected=NO;
    btn11.selected=NO;
    
    btnCurrent.selected=YES;
}
-(void)ShowOverlayTutorial
{
    
    IOverlayView*  overly=[IOverlayView ViewWithFrame:self.view.frame];
    overly.delegate=self;
    
    overly.arrImages=[[NSMutableArray alloc]initWithObjects:@"tutorial_page9_overlay.png",@"tutorial_page10_overlay.png",@"tutorial_page11_overlay.png",@"tutorial_page12_overlay.png",@"tutorial_page13_overlay.png",@"tutorial_page14_overlay.png",@"tutorial_page15_overlay.png",@"tutorial_page16_overlay.png",@"tutorial_page17_overlay.png",@"tutorial_page18_overlay.png",@"tutorial_page19_overlay.png",@"tutorial_page20_overlay.png",@"tutorial_page21_overlay.png",@"tutorial_page22_overlay.png",@"tutorial_page23_overlay.png",@"tutorial_page24_overlay.png",@"tutorial_page25_overlay.png",nil];
    
    [ObjApp_Delegate.window addSubview:overly];
    
}
-(void)didAllSlidesFinished:(UIView *)view
{
    [view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
