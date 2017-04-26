//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Ridmal Choudhary on 9/23/15.
//  Copyright (c) 2015 SquareBits Pvt Ltd. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "UIImageView+WebCache.h"
@implementation DraggableViewBackground
{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    UIButton* checkButton;
    UIButton* xButton;
    UIButton* btnInfo;
    UIButton* btnNext;
    UIImageView *imgLine;
    UIImageView *imgBackGround;
    UIView *navigationView;
    UIButton *btnBack;
    UILabel *lblTitle;
    RemoteImageView *imgRestaurant;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE    = 2; //%%% max number of cards loaded at any given time, must be greater than 1
//static const float Next_btn_Height  = 0.0617;
//static const float Close_btn_Height = 0.1321;
//static const float Info_btn_Height  = 0.0652;
//static const float Label_Height     = 0.0317;
//static const float Label_Width      = 0.1514;
//static const float Close_btn_X      = 0.1438;
//static const float Close_btn_Y      = 0.7518;
//static const float Ok_btn_X         = 0.6219;
//static const float Info_btn_X       = 0.4469;
//static const float Info_btn_Y       = 0.7553;


@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        //temp
        exampleCardLabels = App_Delegate.currentUser.arrFriends;//[[NSArray alloc]initWithObjects:@"", nil];
        
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
//        [self loadCards];
    }
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
//    float x = self.frame.size.height * Close_btn_X;
//    float y = self.frame.size.height * Close_btn_Y;
//    float height = self.frame.size.height * Close_btn_Height;
//    xButton = [[UIButton alloc] initWithFrame:CGRectMake(46, self.frame.size.height-height-20, height, height)];
//    x = self.frame.size.height * Ok_btn_X;
//    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(210, self.frame.size.height-height-20, height, height)];
// 
//    [xButton setBackgroundImage:[UIImage imageNamed:@"icn_close"] forState:UIControlStateNormal];
//    [checkButton setBackgroundImage:[UIImage imageNamed:@"icn_ok"] forState:UIControlStateNormal];
// 
//     [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
//    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:xButton];
//    [self addSubview:checkButton];
 }



-(void)noDataLeft
{
      NSLog(@"No Data Left");
     [self removeFromSuperview];

}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    
    
    
   // NSString *str=[exampleCardLabels objectAtIndex:index];
    
    
     NSDictionary *dict = [App_Delegate.currentUser.arrFriends objectAtIndex:index];
    
    NSString *imgURL =  [dict objectForKey:@"profile_image"];

     NSString *name = [dict objectForKey:@"username"];
     NSString *score =@"0";[dict objectForKey:@"score"]; //
    float height = self.frame.size.height;
    float width = self.frame.size.width - 36;
    
    
    
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(18, 0, width, height)];
    
    // for random friends view is changed so handling this with tag 301
    if (self.tag==301) {
        imgRestaurant = [[RemoteImageView alloc] initWithFrame:CGRectMake(71,80, 173, 173)];
        draggableView.frame=CGRectMake(0, 0, self.frame.size.width, height);
        
        imgRestaurant.layer.cornerRadius=86.5;
        imgRestaurant.layer.masksToBounds=YES;
    }
    else
    {
        imgRestaurant = [[RemoteImageView alloc] initWithFrame:CGRectMake(0, 0, width, height-3)];
    }
    
    
    UILabel *lbl,*lblScore;
    
    UIFont *font=[UIFont fontWithName:@"DINNextRoundedLTW01-Bold" size:22.0];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,280, self.frame.size.width, 30)];
    lblScore = [[UILabel alloc] initWithFrame:CGRectMake(0,315, self.frame.size.width, 30)];
  

    lbl.textColor=[UIColor whiteColor];
    lbl.textAlignment=NSTextAlignmentCenter;
    
    lblScore.textColor=[UIColor whiteColor];
    lblScore.textAlignment=NSTextAlignmentCenter;

    
    lbl.font=font;
    lblScore.font=font;
    
    
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:self.frame];
     imageview.image=[UIImage imageNamed:@"bg.png"];
    [draggableView addSubview:imageview];
    
    draggableView.tag=index;
    
     [draggableView addSubview:imgRestaurant];

    UIButton*  xButton1,*checkButton1;
    
    
    
    
    if (self.tag==301)
    {

        xButton1 = [[UIButton alloc] initWithFrame:CGRectMake(50, self.frame.size.height-130, 50, 50)];
        checkButton1 = [[UIButton alloc]initWithFrame:CGRectMake(200, self.frame.size.height-130, 65, 50)];

    }
    else
    {
        xButton1 = [[UIButton alloc] initWithFrame:CGRectMake(50, self.frame.size.height-80, 50, 50)];
        checkButton1 = [[UIButton alloc]initWithFrame:CGRectMake(170, self.frame.size.height-80, 50, 50)];

    }
    
    
    [xButton1 setBackgroundImage:[UIImage imageNamed:@"ic_red_cross_big"] forState:UIControlStateNormal];
    [checkButton1 setBackgroundImage:[UIImage imageNamed:@"ic_green_check_big"] forState:UIControlStateNormal];
    
    [xButton1 addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    [checkButton1 addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [draggableView addSubview:xButton1];
    [draggableView addSubview:checkButton1];

        
        
        
    if (self.tag==301) {
        
//        imgRestaurant.image = [UIImage imageNamed:@"profile_pic_big"];
        
        [imgRestaurant sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"profile_pic_placeholder"]];

    }
    else
    {
        imgRestaurant.image = [UIImage imageNamed:@"popup_invite"];
        
    }
    
    if ([name isKindOfClass:[NSString class]]) {
        
        name=[name uppercaseString];
    }
    
    
    if ([[UIScreen mainScreen]bounds].size.height<500) {
        
        lblScore.hidden=YES;
    }
    
    lblScore.text=[NSString stringWithFormat:@"High Score: %@",score];// @"High Score: 50";
    lbl.text=name;//@"SAM FORMAN";
     [draggableView addSubview:lbl];
    [draggableView addSubview:lblScore];
     draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            if (i<numLoadedCardsCap) {
                [loadedCards addObject:newCard];
            }
        }
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
            
            [self bringSubviewToFront:xButton];
            [self bringSubviewToFront:checkButton];
        }
    }
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    if (loadedCards.count==0)
    {
        [Anagrams_NotificationCenter postNotificationName:MoveBackWhenDataBlank object:nil];
        [self noDataLeft];
    }

}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(DraggableView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }

    NSDictionary *dict=[ObjApp_Delegate.currentUser.arrFriends objectAtIndex:card.tag];
 
    [[NSNotificationCenter defaultCenter]postNotificationName:NodataLeftToSlide object:dict];

    if (loadedCards.count==0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:Nodataleft_after_AcceptRequest object:nil];

    }

}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonOkRestaurantPressed" object:nil];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonCloseRestaurantPressed" object:nil];
}

-(void)btnBackClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonBackPressed" object:nil];
}

-(void)btnRestaurantInfoClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonRestaurantInfoPressed" object:nil];
}

-(void)btnNextClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonNextPressed" object:nil];
}

@end
