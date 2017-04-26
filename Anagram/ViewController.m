//
//  ViewController.m
//  Anagram
//
//  Created by Ashok Choudhary on 05/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//
#import "HomeVC.h"
#import "ViewController.h"
#import "DraggableViewBackground.h"
#import "TileView.h"
#import "BeginVC.h"
#import "Lexicontext.h"
#define  lettersC          @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define  lettersConsonant  @"BCDFGHJKLMNPQRSTVWXYZ"
#define  lettersWovels     @"AEIOU"


#define labelwidthAndheight  30
#define xPosition  80
#define yPosition  200

#define stackTapSound          @"STACK_TAP"
#define wordSUbmitSound        @"WORD_SUBMIT"
#define wordWrongSound         @"WRONG_WORD"

#define gameTimeoutSeconds    180;  //500;//

#define turnFinishedSeconds   10;

@interface ViewController ()
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    counter=0;
    Xcounter=0;
    Ycounter=0;
    gameOwnerScore=0;
    gameOpponentScore=0;
    
    submitClickedOponent=0;
    submittClickedOwner=0;
    
    consonantCounter=0;

    green= [UIColor colorWithRed:126.0/255.0 green:211.0/255.0 blue:33.0/255.0 alpha:1.0];
    red= [UIColor colorWithRed:241.0/255.0 green:62.0/255.0 blue:0 alpha:1.0];
    yellow= [UIColor colorWithRed:255.0/255.0 green:252.0/255.0 blue:0 alpha:1.0];

    
    arrHelpingVerb=[[NSMutableArray alloc]initWithObjects:@"am",@"are",@"is",@"was",@"were",@"be",@"being",@"been",@"have",@"has",@"had",@"shall",@"will",@"do",@"does",@"did",@"may",@"must",@"might",@"can",@"could",@"would",@"should",@"oughtto",@"having",@"and", nil];

    
    Lexdictionary=[Lexicontext sharedDictionary];
    
    progressCircle.state = CHCircleGaugeViewStateScore;
    progressCircle.trackWidth = 1;
    progressCircle.gaugeWidth = 3;
    progressCircle.gaugeStyle = CHCircleGaugeStyleOutside;
    progressCircle.trackTintColor = [UIColor clearColor];
    progressCircle.gaugeTintColor = green;
    progressCircle.noDataString=@"";
    progressCircle.unitsString=@"%";
    progressCircle.textColor=[UIColor clearColor];
   [progressCircle setValue:1.0 animated:YES];
    

    
//    if ([[Anagrams_Defaults objectForKey:@"isOvelayShown"]isEqualToString:@"Y"])
//    {
        [self initializetheGameNotificationsAndVariables];
//    }
//    else{
//
//        [Anagrams_Defaults setObject:@"Y" forKey:@"isOvelayShown"];
//        [Anagrams_Defaults synchronize];
//        [self ShowOverlayTutorial];
//    }
    
}



-(void)initializetheGameNotificationsAndVariables
{
    arrSelectedCharachtars =[[NSMutableArray alloc]init];
    
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    
    arrCurrentTilesInPOOL     =  [[NSMutableArray alloc]init];
    arrStealedCharsMainArray  =  [[NSMutableArray alloc]init];
    arrStealCharsTemparray    =  [[NSMutableArray alloc]init];
    arrOpponentAllWord        =  [[NSMutableArray alloc]init];
    arrUserALLWords           =  [[NSMutableArray alloc]init];
    imgOnlineOrOff.hidden=YES;
    imgOnlineOrOffOpponent.hidden=YES;
    

    if (timer4Minutes) {
        [timer4Minutes invalidate];
        timer4Minutes=nil;
    }
    if (timer15Sec) {
        [timer15Sec invalidate];
        timer15Sec=nil;
    }
    
    if (self.isOpponent)
    {
        consonantCounter=2;
        [self changeUserStatus:NO];
        [self performSelector:@selector(shouldShowOnline) withObject:nil afterDelay:10.0];
        
    }
    else
    {
        [self changeUserStatus:YES];
    }
    
    counter15sec=turnFinishedSeconds;
    counter4Minutes=gameTimeoutSeconds;
    
    timer4Minutes=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateGameTimer) userInfo:nil repeats:YES];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(stackTapped:) name:STACK_TAPPED object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(submitWord:) name:SUBMIT_WORD object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(wordCompleted:) name:WORD_COMPLETED object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(submitWordError:) name:SUBMIT_WORD_ERROR object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(gameResult:) name:GAME_RESULT object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(playerWon:) name:PLAYER_WON object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(gameTimedOut:) name:GAME_TIMEOUT object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(gameQuitted) name:Game_Quit_User object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(xmppConnectedSuccessfully) name:kServerLoginSuccess object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(xmppDisconnected) name:kServerDisconnect object:nil];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];

    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationRejected) name:INVITATION_REJECTED object:nil];

    
    arrALlCharactersMain=[self.dictMain objectForKey:@"character_stack"];
    [self shuffleAnArray];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    lblGameID.text=[NSString stringWithFormat:@"%@,%@",[self.dictMain objectForKey:@"game_id"],build];
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    app.currentGameId=[NSString stringWithFormat:@"%@",[self.dictMain objectForKey:@"game_id"]];

}


-(void)shuffleAnArray

{
    
    arrWovelsArray=[[NSMutableArray alloc]init];
    arrConsonatsArray=[[NSMutableArray alloc]init];
    
    arrShuffledArray=[[NSMutableArray alloc]initWithArray:arrALlCharactersMain];

    
    
    for (int i=0; i<arrShuffledArray.count; i++) {
        
        NSDictionary *dict=[arrShuffledArray objectAtIndex:i];
        
        NSString *charValue=[dict objectForKey:@"char"];
        
        if ([charValue isEqualToString:@"A"]||[charValue isEqualToString:@"E"]||[charValue isEqualToString:@"I"]||[charValue isEqualToString:@"O"]||[charValue isEqualToString:@"U"]) {
            [arrWovelsArray addObject:dict];
        }
        else
        {
            [arrConsonatsArray addObject:dict];
        }
    }
    
//    NSInteger count = [arrShuffledArray count];
//    for (NSInteger i = 0; i < count; ++i) {
//        // Select a random element between i and end of array to swap with.
//        NSInteger nElements = count - i;
//        NSInteger n = (random() % nElements) + i;
//        [arrShuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
//    }

}




-(void)updateTimeandStatusImage
{
    
    
  //   if (ispaused) {
    //     return;
   // }
    
    
    counter15sec = counter15sec-1;
    
     lbl15Sec.text=[NSString stringWithFormat:@"%d",counter15sec];
    
    
    if (counter15sec<=3)
    {
        imgStatusIndicator.image=[UIImage imageNamed:@"img_circle_red"];

        progressCircle.gaugeTintColor = red;

    }
    else if( counter15sec<=5)
    {
        imgStatusIndicator.image=[UIImage imageNamed:@"img_circle_yellow"];

        progressCircle.gaugeTintColor = yellow;

    }
    else
    {
        imgStatusIndicator.image=[UIImage imageNamed:@"img_circle_green"];
        
        progressCircle.gaugeTintColor = green;

    }

    
    
    if (counter15sec==0)
    {
 
         counter15sec=11;
        
        if (shouldShowUserOnline) {
            [self btnclced:nil];
            [self changeUserStatus:NO];
          }
        else
        {
            [self changeUserStatus:YES];
        }

        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(shouldShowOnline) withObject:nil afterDelay:10.0];
        
    }
    
    float prog=counter15sec/10.0;
    [progressCircle setValue:prog animated:NO];

}



-(void)updateGameTimer
{
    
 //   if (ispaused) {
        
   //     return;
    //}
    
//    NSLog(@"Main Game Timer is being called");
    counter4Minutes=counter4Minutes-1;
    int seconds = counter4Minutes % 60;
    int minutes = (counter4Minutes - seconds) / 60;
    lbl4Mins.text = [NSString stringWithFormat:@"%d:%.2d", minutes, seconds];
    
    lblPuaseTime.text=lbl4Mins.text;

    
    if (counter4Minutes==0)
    {
        if (gameOwnerScore==0&&gameOpponentScore==0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Game timed out" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=101;
            [alert show];
        }
        else if(gameOpponentScore>gameOwnerScore)
        {
            lblLostText.text=[NSString stringWithFormat:@"You Lost to opponent by %d points",(gameOpponentScore-gameOwnerScore)];
            lblLostHeader.text=@"YOU LOST";
            [self showGameLoosingPopup];
        }
        else if(gameOwnerScore>gameOpponentScore)
        {
            lblWinnerText.text=[NSString stringWithFormat:@"You beat opponent by %d points",(gameOwnerScore-gameOpponentScore)];
            [self showGameWinningPopUp];
        }
        else if(gameOpponentScore==gameOwnerScore)
        {
             lblLostText.text=[NSString stringWithFormat:@"Game tie"];
            lblLostHeader.text=@"GAME TIE";

             [self showGameLoosingPopup];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [timer15Sec invalidate];
        [timer4Minutes invalidate];
        timer4Minutes=nil;
        timer15Sec=nil;
     }
}



-(void)showGameWinningPopUp
{
    vwVictroy.hidden=NO;
    vwVictroy.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    vwVictroy.alpha=0;

    [UIView animateWithDuration:0.3  animations:^{
        vwVictroy.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        vwVictroy.alpha=1;
        [ObjApp_Delegate.window addSubview:vwVictroy];
    }];
}


-(void)showGameLoosingPopup
{

    vwLost.hidden=NO;
    vwLost.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    vwLost.alpha=0;
    
    [UIView animateWithDuration:0.3  animations:^{
        
        vwLost.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        vwLost.alpha=1;
        [ObjApp_Delegate.window addSubview:vwLost];
    }];

}



-(void)viewDidAppear:(BOOL)animated
{
    [self addFramesinArrayOfAllPool];
}




-(void)addFramesinArrayOfAllPool
{
   

    arrRandomFrames=[[NSMutableArray alloc]init];
    
//    int tagCounter=0;
    
    for (int i=0; i<7; i++)
    {
        for (int j=0; j<5; j++)
        {
        
            CGRect frame=CGRectMake(0, 0, labelwidthAndheight, labelwidthAndheight);
            CGFloat xP=xPosition+((labelwidthAndheight+2)*i);
            CGFloat yP=yPosition+((labelwidthAndheight+2)*j);
            
            frame.origin.x=xP;
            frame.origin.y=yP;
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            
            [dict setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
//            [dict setObject:[NSString stringWithFormat:@"%D",tagCounter] forKey:@"tag"];

            [dict setObject:@"0" forKey:@"isUsed"];
//            [arrRandomFrames addObject:[NSValue valueWithCGRect:frame]];
            [arrRandomFrames addObject:dict];
         }
    }
    
    
   
}




-(IBAction)btnclced:(id)sender
{
    [self addTilesInPoolForCurrentUser];
}



-(NSString*)returnRandomString
{
    NSString *strRandom;

    NSArray *arrTemp=[[NSArray alloc]initWithObjects:@"A",@"A",@"A",@"A",@"A",@"B",@"B",@"C",@"C",@"C",@"C",@"D",@"D",@"D",@"D",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"F",@"F",@"F",@"F",@"G",@"G",@"H",@"H",@"H",@"H",@"H",@"I",@"I",@"I",@"I",@"I",@"J",@"K",@"L",@"L",@"L",@"L",@"L",@"M",@"M",@"M",@"M",@"N",@"N",@"N",@"N",@"N",@"O",@"O",@"O",@"O",@"O",@"O",@"P",@"P",@"P",@"Q",@"R",@"R",@"R",@"R",@"R",@"S",@"S",@"S",@"S",@"S",@"T",@"T",@"T",@"T",@"T",@"T",@"T",@"U",@"U",@"U",@"U",@"V",@"V",@"W",@"W",@"W",@"X",@"Y",@"Y",@"Y",@"Z", nil];
    
    NSInteger rH = [arrTemp count]-1;
    NSInteger rLow = 0;
    NSInteger randomPosition = arc4random() % (rH-rLow+1) + rLow;

    strRandom=[arrTemp objectAtIndex:randomPosition];
    
    return strRandom;
}

-(NSDictionary *) randomStringWithLength
{
    
    
    
    
//      NSInteger rH = [arrShuffledArray count]-1;
//      NSInteger rLow = 0;
//      NSInteger randomPosition = arc4random() % (rH-rLow+1) + rLow;
    
    
//    NSString *charV=[arrShuffledArray objectAtIndex:randomPosition];
//    [arrShuffledArray removeObjectAtIndex:randomPosition];

    
//      NSDictionary  *DictChar=[arrShuffledArray objectAtIndex:randomPosition];
//
////       NSString *charV=[DictChar objectForKey:@"char"];
//      [arrShuffledArray removeObjectAtIndex:randomPosition];

//     NSDictionary  *DictChar=[arrShuffledArray firstObject];
//    [arrShuffledArray removeObjectAtIndex:0];

    
    
    
    
    
    if (consonantCounter>=2)
    {
        consonantCounter=0;
        NSLog(@"vowel selected");
        
        if (arrWovelsArray.count>0)
        {
            
            NSInteger rH = [arrWovelsArray count]-1;
            NSInteger rLow = 0;
            NSInteger randomPosition = arc4random() % (rH-rLow+1) + rLow;
            NSDictionary  *DictChar=[arrWovelsArray objectAtIndex:randomPosition];
            [arrWovelsArray removeObjectAtIndex:randomPosition];
            return DictChar;
            
        }
        
    }
    else
    {
        consonantCounter=consonantCounter+1;
        NSLog(@"consonant selected");
        if (arrConsonatsArray.count>0)
        {
            NSInteger rH = [arrConsonatsArray count]-1;
            NSInteger rLow = 0;
            NSInteger randomPosition = arc4random() % (rH-rLow+1) + rLow;
            NSDictionary  *DictChar=[arrConsonatsArray objectAtIndex:randomPosition];
            
            if (![self chekCharacterAlreadyPresentInStack:DictChar]) {
                [arrConsonatsArray removeObjectAtIndex:randomPosition];
                return DictChar;

            }
            else
            {
                NSInteger rH = [arrConsonatsArray count]-1;
                NSInteger rLow = 0;
                NSInteger randomPosition = arc4random() % (rH-rLow+1) + rLow;
                NSDictionary  *DictChar=[arrConsonatsArray objectAtIndex:randomPosition];
                return DictChar;
            }
            
        }
        
    }
    

    return nil;
    
//    return DictChar;
    
    
  /*
    int len=1;
    
    NSString *letters =lettersC ;
    int rangeHigh = 25;

    
    
    if (vowelCounter>=2)
    {
   
        vowelCounter=0;
        letters =lettersConsonant ;

        NSLog(@"consonant selected");
        rangeHigh=20;
    }
    else
    {
        letters=lettersWovels;
        NSLog(@"vowels selected");
        rangeHigh=4;
        vowelCounter=vowelCounter+1;


    }

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    int rangeLow = 0;

    int randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;
    [randomString appendFormat: @"%C", [letters characterAtIndex: randomNumber]];
    if (rangeHigh==4) {
     
        if ([randomString isEqualToString:lastVowel])
        {
            randomString = [NSMutableString stringWithCapacity: len];

            int randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;

            [randomString appendFormat: @"%C", [letters characterAtIndex: randomNumber]];

        }
        lastVowel=randomString;
        

    }
    else if (rangeHigh==24)
    {

        
        if ([randomString isEqualToString:lastConsonant]) {
            
            randomString = [NSMutableString stringWithCapacity: len];
            int randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;

            [randomString appendFormat: @"%C", [letters characterAtIndex: randomNumber]];
            
        }
        
        lastConsonant=randomString;

    }

    
    return randomString;
   */
}


-(BOOL)chekCharacterAlreadyPresentInStack:(NSDictionary*)dict
{
    
    BOOL isWordAleradyExists=NO;
    
    NSString *strChar=[[dict objectForKey:@"char"] lowercaseString];
    for (TileView *t in arrCurrentTilesInPOOL) {
        
        if ([t isKindOfClass:[TileView class]]) {
            
            if ([[t.lblT.text lowercaseString] isEqualToString:strChar]) {
                
                NSLog(@"Duplicate Char found %@",strChar);
                return YES;
            }
        }
    }
    
    return isWordAleradyExists;
}



-(void)addTilesInPoolForCurrentUser
{

    
    if (arrRandomFrames.count==0)
    {
        
        return;
    }
    
    if (arrShuffledArray.count==0) {
        return;
    }

//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    
    if (![App_Delegate isXmppConnectedAndAuthenticated]) {
        
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
  
    
    NSDictionary *dict=[self randomStringWithLength];
    
    
    if (!dict) {
        return;
    }
    
    NSString *charV=[dict objectForKey:@"char"];
    view.lblT.text=[charV uppercaseString];
    
    
    [self sendStackTapSubject:dict];
     
    
    view.dictCharData=[dict mutableCopy];
    
    
  //  view.lblT.text=[self returnRandomString];
     
    [self.view addSubview:view];
    [view clipsToBounds];
    [view addGestureRecognizer:tap];
    
    [arrCurrentTilesInPOOL addObject:view];
    

   [UIView animateWithDuration:0.3 animations:^
   {
       view.frame=rectNewView;
       
   }completion:^(BOOL finished) {
 
       [self playGameSounds:stackTapSound];

   }];
    
  
    
}


-(void)addTilesInPoolForOpponentTapped:(NSDictionary*)dict
{
    
    if (arrRandomFrames.count==0)
    {
        
        return;
    }
    
    
    if (arrShuffledArray.count==0) {
        return;
    }

    
    //    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    
    
    
    
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
        // do some stuff
        return;
    }
    
    
    NSString *charV=[dict objectForKey:@"char"];
    view.lblT.text=[charV uppercaseString];
    
    
  //  if ([ObjApp_Delegate.currentUser.userID isEqualToString:[self.dictMain objectForKey:@"user_id"]])
    //{
//        [self sendStackTapSubject:dict];
//    }
    
    view.dictCharData=[dict mutableCopy];

    
    [self.view addSubview:view];
    [view clipsToBounds];
    [view addGestureRecognizer:tap];
    
    [arrCurrentTilesInPOOL addObject:view];

    
    [UIView animateWithDuration:0.3 animations:^
     {
         view.frame=rectNewView;
         
     }completion:^(BOOL finished) {
         
         [self playGameSounds:stackTapSound];

     }];
    
    
    
}




/*
-(void)setFrameWithTimeInterval:(NSDictionary*)dict
{
 
 NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
 [dict setObject:view forKey:@"view"];
 [dict setObject:[NSValue valueWithCGRect:rectNewView] forKey:@"frame"];
 
 [self setFrameWithTimeInterval:dict];
 
 [self performSelector:@selector(spinTheLabel:) withObject:view afterDelay:1];

 
    CGRect frame=[[dict valueForKey:@"frame"] CGRectValue];
    UIView *view=[dict objectForKey:@"view"];
    
    CGRect viewFrame=view.frame;
    
    if (viewFrame.origin.x<frame.origin.x)
    {
        viewFrame.origin.x=viewFrame.origin.x+1;
        view.frame=viewFrame;
        [self performSelector:@selector(setFrameWithTimeInterval:) withObject:dict afterDelay:0.0001];
//        [self spinTheLabel:view];
    }
    
}
*/


-(CGRect)getRandomFrame:(CGRect)oldFrame  Tv:(TileView*)tilView
{
    CGRect newframe=oldFrame;
    
    
    /*
    if (Xcounter>6) {
        Xcounter=0;
    }
    
    if (Ycounter>=5) {
        
        Ycounter=0;
        Xcounter=Xcounter+1;
    }
    
    CGFloat xP=xPosition+(labelwidthAndheight*Xcounter);
    CGFloat yP=yPosition+(labelwidthAndheight*Ycounter);
    
    Ycounter=Ycounter+1;
    
    newframe.origin.x=xP;
    newframe.origin.y=yP;

    return newframe;
     */

//    NSInteger randomNumberx =    arc4random() % [arrXs count];
//     NSInteger randomNumbery =    arc4random() % [arrYs count];

    
  //  NSInteger randomNumber =    arc4random() % [arrRandomFrames count];

    
//    float x=[[arrXs objectAtIndex:randomNumberx]floatValue];
//    
//    float y=[[arrYs objectAtIndex:randomNumbery]floatValue];
//
//    newframe.origin.x=x;
//    newframe.origin.y=y;
//    
//    
//    NSLog(@"x-is %f, y-is %F",x,y);
    
    

    
    
//    NSMutableDictionary *dict=[arrRandomFrames objectAtIndex:randomNumber];
    
//    newframe=[[dict objectForKey:@"frame"]CGRectValue];
    
//    [dict setObject:@"1" forKey:@"isUsed"];
//
//    tilView.dict=dict;
//    newframe =[[arrRandomFrames objectAtIndex:randomNumber]CGRectValue];
    
  //  [arrRandomFrames removeObjectAtIndex:randomNumber];
   
    
    newframe=[self getFreeSlotFrame:tilView];
    return newframe;
}

//ashokjangu@gmail.com





-(void)handleTap:(UITapGestureRecognizer*)tap
{
    
    [self playGameSounds:stackTapSound];

    
    TileView *tView=(TileView*)tap.view;
 
    
    tView.lblT.textColor=[UIColor whiteColor];
    
     if ([tView isKindOfClass:[TileView class]])
    {
        if (tView.isSelected==NO)
        {
       //     tView.layer.borderColor=[UIColor yellowColor].CGColor;
        //    tView.layer.borderWidth=1.0;

            
             tView.isSelected=YES;
            [arrSelectedCharachtars addObject:tView];
            
//           if (isStealModeOn)
//            {
                [arrStealedCharsMainArray addObject:tView];
//            }
            
            [tView removeFromSuperview];
            
            // this method will add these selected values to USERBOX
             if (isStealModeOn)
             {

                [self fillTheTilesInUserBoxAfterSelected];
                
            }
            else
            {
                [self fillTheTilesInUserBoxAfterSelected];

            }
         }
        else
        {
            tView.isSelected=NO;
            
            
            
            
            [arrSelectedCharachtars removeObject:tView];
            [arrStealedCharsMainArray removeObject:tView];
            
            // add The tile view back to Pool when tappad second time

            if (isStealModeOn)
            {
                [self addTileViewBackToPoolForStealMode:tView];
            }
            else
            {
                [self addTileViewBackToPool:tView];
            }
            
        }
    }
    
    if (isStealModeOn) {
        
        if (arrSelectedCharachtars.count>0)
        {
             isTileSelectedFromPool=YES;
        }
    }
 }





-(void)addTileViewBackToPool:(TileView*)tVIew
{
    tVIew.layer.borderColor=[UIColor clearColor].CGColor;
    tVIew.layer.borderWidth=1.0;
    

    CGRect rect=CGRectZero;
    rect =[[tVIew.dictTileFrame objectForKey:@"frame"] CGRectValue];
    [self.view addSubview:tVIew];
    tVIew.frame=rect;
 
    //arrange the order back to latest word after removing any new word from here.
    [self fillTheTilesInUserBoxAfterSelected];
}







- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}


-(BOOL)checkIfThereisAnyWordWithThisString:(NSString*)word
{

    NSLog(@"meaning of the word %@",[Lexdictionary definitionFor:@"AND"]);
    
    BOOL ifDefiniationExists=NO;
    
     if ([Lexdictionary containsDefinitionFor:word])
    {
 
        ifDefiniationExists=YES;
    }
    
    
    if (ifDefiniationExists==NO) {
        
        if ([arrHelpingVerb containsObject:[word lowercaseString]]) {
            
            ifDefiniationExists=YES;
        }
    }
    
    /*
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:word])
    {
//       UIReferenceLibraryViewController* ref =
//       [[UIReferenceLibraryViewController alloc] initWithTerm:word];
//       [self presentViewController:ref animated:YES completion:nil];
        return YES;
    }
    */
    return ifDefiniationExists;
}



-(void)abc
{
//    NSString *partialWord = @"NTLPAE";
//    UITextChecker *textChecker = [[UITextChecker alloc] init];
//    NSArray *completions = [textChecker completionsForPartialWordRange:NSMakeRange(0, partialWord.length) inString:partialWord language:@"en"];
//    NSArray *completions1 = [textChecker guessesForWordRange:NSMakeRange(0, partialWord.length) inString:partialWord language:@"en"];

}










-(void)spinTheLabel:(UIView*)lbl
{
    CATransition* transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = @"flip";
    transition.subtype = @"fromRight";
    transition.duration = 1.0;
    transition.repeatCount =0;
    [lbl.layer addAnimation:transition forKey:@"transition"];


}


-(void)abcd:(UILabel*)view
{


    // Add the horizontal animation
//    CABasicAnimation *horizontal = [CABasicAnimation animationWithKeyPath:@"position.x"];
//    horizontal.delegate = self;
//    horizontal.fromValue = [NSNumber numberWithFloat:25.0];
//    horizontal.toValue = [NSNumber numberWithFloat:50.0];
//    horizontal.repeatCount = 0;
//    horizontal.duration = 6;
//    horizontal.autoreverses = YES;
//    horizontal.beginTime = 0; // ignore delay time for now
//    horizontal.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [view.layer addAnimation:horizontal forKey:@"horizontal_animation"];
    
    // Add the vertical animation
    CABasicAnimation *vertical = [CABasicAnimation animationWithKeyPath:@"position.x"];
    
  //  vertical.delegate = self;
    vertical.fromValue = [NSNumber numberWithFloat:100];
    vertical.toValue = [NSNumber numberWithFloat:200];
    vertical.repeatCount = 0;
    vertical.duration = 1;
    vertical.autoreverses = NO;
    vertical.beginTime = 0; // ignore delay time for now
    vertical.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [view.layer addAnimation:vertical forKey:@"vertical_animation"];
    

    [self spinTheLabel:view];
}



-(IBAction)btnPauseClicked:(id)sender
{
//    ispaused=YES;
    
    lblPuaseTime.text=lbl4Mins.text;
    viewPauseGame.frame=self.view.frame;
    [ObjApp_Delegate.window addSubview:viewPauseGame];
    [ObjApp_Delegate.window bringSubviewToFront:viewPauseGame];
    viewPauseGame.alpha=0.0;
    viewPauseGame.transform=CGAffineTransformMakeScale(.1, .1);
    [UIView animateWithDuration:0.3 animations:^{
        viewPauseGame.alpha=1.0;
        viewPauseGame.transform=CGAffineTransformMakeScale(1,1);
    }];
}
//btn continue clicked on Pause view
-(IBAction)btnContinueClicked:(id)sender
{
    ispaused=NO;
    [viewPauseGame removeFromSuperview];
}

//btn quit clicked on Pause View
-(IBAction)btnQuitClicked:(id)sender
{
    
    [self sendGameQuittedPacket];
    
    [timer15Sec invalidate];
    timer15Sec=nil;
    [timer4Minutes invalidate];
    timer4Minutes=nil;
    [viewPauseGame removeFromSuperview];
    [self removeAllObservers];
     HomeVC *vc=[[HomeVC alloc]init];
     [App_Delegate changeRootVieController:vc];
   // [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)btnSubmitClicked:(id)sender
{

    [self performSelector:@selector(enableSubmitButton) withObject:nil afterDelay:1.5];

    
    if (isStealModeOn)
    {
        
        
        // check if user selected whole word from the opponent users word
        
        BOOL ifanyTileExistsOpponent=NO;

        if (refViewForSteal_Opponent) {
            
            for (TileView *T in refViewForSteal_Opponent.subviews) {
                
                if ([T isKindOfClass:[TileView class]]) {
                    ifanyTileExistsOpponent=YES;
                    break;
                }
            }
            
            
            if (ifanyTileExistsOpponent) {
//                [[[UIAlertView alloc]initWithTitle:appname message:@"Please select Whole word from opponent users words" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                [self setAllTilesBackIfAnswerIsWrong];

                return;
            }

        }
        
        
        // if user not select all charachters from his own words then he should not be able to proceed further
        // first he should select all the charachters and then press submit
        
        BOOL ifanyTileExistsInUserView=NO;

        if (refViewForSteal_User) {
            
            for (TileView *T in refViewForSteal_User.subviews) {
                
                if ([T isKindOfClass:[TileView class]]) {
                    ifanyTileExistsInUserView=YES;
                    break;
                }
            }
            
            if (ifanyTileExistsInUserView) {
//                [[[UIAlertView alloc]initWithTitle:appname message:@"Please select Whole word from your words" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                [self setAllTilesBackIfAnswerIsWrong];

                return;
            }

        }

        //if user select tiles from his words only and he did not click any other tile from pool or opponents word then he should not be able to go further
        if ( !refViewForSteal_Opponent&&refViewForSteal_User) {
            
        
            if (arrSelectedCharachtars.count==0) {
                
//                [[[UIAlertView alloc]initWithTitle:nil message:@"Please select minimum one character from pool" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                [self setAllTilesBackIfAnswerIsWrong];

                return;

            }
        }
        
        if ( refViewForSteal_Opponent&&!refViewForSteal_User) {
            
            
            if (arrSelectedCharachtars.count==0) {
                
//                [[[UIAlertView alloc]initWithTitle:nil message:@"Please select minimum one character from pool" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                
                [self setAllTilesBackIfAnswerIsWrong];

                return;
                
            }
        }

        
        
        
        NSMutableArray *arrViews=[[NSMutableArray alloc]init];
        NSString *WholeWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrStealedCharsMainArray.count, labelwidthAndheight)];
        for (int i=0; i<arrStealedCharsMainArray.count; i++)
        {
            TileView *tielView=[arrStealedCharsMainArray objectAtIndex:i];
            
            TileView *viewNew=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewNew.lblT.text=tielView.lblT.text;
            [view addSubview:viewNew];
            
            WholeWord=[WholeWord stringByAppendingString:tielView.lblT.text];
            [arrViews addObject:tielView];
        }
        
        
        
        if (WholeWord.length>2)
        {
            if ([self checkIfThereisAnyWordWithThisString:WholeWord])
            {
                
                if (![self checkIfWordIsMadeWith_S_ES_ING_Or_verbForm:WholeWord])
                {
                    btnSubmit.userInteractionEnabled=NO;
                    [self sendWordSubmittedPacketInStealMode];

                }
                else
                {
//                    [[[UIAlertView alloc]initWithTitle:appname message:@"You cant make new word by adding s,es,ed,ing in already made words" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                    
                    [self setAllTilesBackIfAnswerIsWrong];

                    
                }

                
             }
            else
            {
             //   [[[UIAlertView alloc]initWithTitle:appname message:@"Word does not depict any meaning" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                
                [self setAllTilesBackIfAnswerIsWrong];

            }
             
        }
        else
        {
//            [[[UIAlertView alloc]initWithTitle:appname message:@"Word length must be greater than equal to three characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            
              [self setAllTilesBackIfAnswerIsWrong];
        }

    }
    else
    {
        NSMutableArray *arrViews=[[NSMutableArray alloc]init];
        NSString *WholeWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrSelectedCharachtars.count, labelwidthAndheight)];
        for (int i=0; i<arrSelectedCharachtars.count; i++)
        {
            TileView *tielView=[arrSelectedCharachtars objectAtIndex:i];
            
            TileView *viewNew=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewNew.lblT.text=tielView.lblT.text;
            [view addSubview:viewNew];
            
            WholeWord=[WholeWord stringByAppendingString:tielView.lblT.text];
            [arrViews addObject:tielView];
        }
        
        
        
        if (WholeWord.length>2)
        {
            if ([self checkIfThereisAnyWordWithThisString:WholeWord])
            {
                
                if (![self checkIfWordIsMadeWith_S_ES_ING_Or_verbForm:WholeWord]) {

                    btnSubmit.userInteractionEnabled=NO;
                    [self sendWordSubmittedPacket];
                 }
                else
                {
//                    [[[UIAlertView alloc]initWithTitle:appname message:@"You cant make new word by adding s,es,ed,ing in already made words" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                    
                    [self setAllTilesBackIfAnswerIsWrong];


                }
            }
            else
            {
               // [[[UIAlertView alloc]initWithTitle:appname message:@"Word does not depict any meaning" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
                
                
                [self setAllTilesBackIfAnswerIsWrong];
            }
            
            
            
        }
        else
        {
//            [[[UIAlertView alloc]initWithTitle:appname message:@"Word length must be greater than equal to three characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];

            [self setAllTilesBackIfAnswerIsWrong];

        }
        
    }
   
    


    
}

-(void)enableSubmitButton
{
    btnSubmit.userInteractionEnabled=YES;
}


-(BOOL)checkIfWordIsMadeWith_S_ES_ING_Or_verbForm:(NSString*)strWord
{
    BOOL isDuplicateForm=NO;
    
    NSString *s = [strWord substringFromIndex: [strWord length] - 1];
    NSString *es = [strWord substringFromIndex: [strWord length] - 2];
    NSString *ing = [strWord substringFromIndex: [strWord length] - 3];

    NSString *sPreWord = [strWord substringToIndex:[strWord length] - 1];
    NSString *esPreWord = [strWord substringToIndex: [strWord length] - 2];
    NSString *ingPreWord = [strWord substringToIndex: [strWord length] - 3];

    
    if ([[es lowercaseString] isEqualToString:@"es"]) {

       isDuplicateForm= [self checkWordAlreadyExistsinBothUsersArrayorNot:esPreWord];
        if (!isDuplicateForm) {
            isDuplicateForm=   [self checkWordAlreadyExistsinBothUsersArrayorNot:sPreWord];
        }
        
    }
    else if ([[s lowercaseString] isEqualToString:@"s"]) {
     isDuplicateForm=   [self checkWordAlreadyExistsinBothUsersArrayorNot:sPreWord];
        
    }
    else if ([[es lowercaseString] isEqualToString:@"ed"]) {
      isDuplicateForm=  [self checkWordAlreadyExistsinBothUsersArrayorNot:esPreWord];
    }
    else if ([[ing lowercaseString] isEqualToString:@"ing"]) {
      isDuplicateForm=  [self checkWordAlreadyExistsinBothUsersArrayorNot:ingPreWord];
    }
    
    return isDuplicateForm;
}


-(BOOL)checkWordAlreadyExistsinBothUsersArrayorNot:(NSString*)strNewWord
{
    BOOL isWordAvailable=NO;
    
    for (BaseViewForTiles *vi in arrUserALLWords) {

        if ([vi isKindOfClass:[BaseViewForTiles class]]) {
            
            if ([[vi.strWordString lowercaseString] isEqualToString:[strNewWord lowercaseString]])
            {
                isWordAvailable=YES;
                return isWordAvailable;
            }
        }
    }

    for (BaseViewForTiles *vi in arrOpponentAllWord) {
        
        if ([vi isKindOfClass:[BaseViewForTiles class]]) {
            
            if ([[vi.strWordString lowercaseString] isEqualToString:[strNewWord lowercaseString]])
            {
                isWordAvailable=YES;
                return isWordAvailable;
            }
        }
    }
 
    return NO;
}




-(void)removAllViewAfterARightAnswer:(NSMutableArray*)arr
{
    for (int i=0; i<arr.count; i++)
    {
         TileView *tl=[arr objectAtIndex:i];
        // here this  will set the all frames value to isUsed 0
        // so whenever charachters are removed from pool then this method will also got called and hence we can insert the new Labels on the empty frames again
         [tl.dictTileFrame setObject:@"0" forKey:@"isUsed"];
         [tl removeFromSuperview];
        
        if ([arrCurrentTilesInPOOL containsObject:tl]) {
            [arrCurrentTilesInPOOL removeObject:tl];
        }

        
    }
}

-(void)setAllTilesBackIfAnswerIsWrong
{
       [self playGameSounds:wordWrongSound];
    
        for (TileView *tVIew in vwUserWordBox.subviews)
        {
            if ([tVIew isKindOfClass:[TileView class]]) {
                
                
                tVIew.layer.borderColor=[UIColor clearColor].CGColor;
                tVIew.layer.borderWidth=1.0;
                
                NSInteger tag=tVIew.my_TAG;
                
                BaseViewForTiles *superViewOfTile;
                
                //if tag is greater then 1000 then it means this tile is stolen from opponent user view
                if (tag>=1000)
                {
                    superViewOfTile=(BaseViewForTiles*)[scrlUser1 viewWithTag:tag];
                }
                else
                {
                    superViewOfTile=(BaseViewForTiles*)[scrlUser2 viewWithTag:tag];
                }
                
                CGRect rect=CGRectZero;
                rect =[[tVIew.dictTileFrame objectForKey:@"frame"] CGRectValue];
                tVIew.frame=rect;
                
                
                //if tile is taken from the scrollview then it will be place back to scrollview and if tile is taken from pool then it will be set back to pool
                if (tVIew.isTilesBelongsToScrollView )
                {
                    tVIew.isSelected=NO;
                    [superViewOfTile addSubview:tVIew];
                }
                else
                {
                    tVIew.isSelected=NO;

                    // this line may cause some problem so please remember this to comment this line
                       [self.view addSubview:tVIew];
                    
                    
                    if ([arrSelectedCharachtars containsObject:tVIew]) {
                        [arrSelectedCharachtars removeObject:tVIew];
                    }
                    
                    if ([arrStealedCharsMainArray containsObject:tVIew]) {
                        [arrStealedCharsMainArray removeObject:tVIew];
                    }
                    
                }
            }
            
        }
    
    [arrSelectedCharachtars removeAllObjects];
    [arrStealCharsTemparray removeAllObjects];
    [arrStealedCharsMainArray removeAllObjects];
 
    isStealModeOn=NO;
    for (TileView *tV in vwUserWordBox.subviews) {
        
        if ([tV isKindOfClass:[TileView class]]) {
            [tV removeFromSuperview];
        }
    }

    refViewForSteal_Opponent=nil;
    refViewForSteal_User=nil;
    [self enableAllViewInScrollViewWhenStealing];
 }



-(void)addWordsInUsersAllwordsScrollView:(NSMutableArray*)arrayViewsToRemoved   arrChars:(NSMutableArray*)arrayChars   O_id:(NSString*)opponent_ID
{
//    NSMutableArray *arrViews=[[NSMutableArray alloc]init];
    
    BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrayViewsToRemoved.count, labelwidthAndheight)];
    NSString *strUserId=App_Delegate.currentUser.userID;
    
    for (int i=0; i<arrayChars.count; i++)
    {
        
        NSMutableDictionary *dict=[arrayChars objectAtIndex:i];
        
        UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
        tapT.numberOfTapsRequired = 1;
        tapT.delegate=self;
        
        
        TileView *viewTile=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
        viewTile.lblT.text= [dict objectForKey:@"char"];
        viewTile.userInteractionEnabled=YES;
        viewTile.dictCharData=dict;
        NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
        [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
        viewTile.dictTileFrame=dictF;
        [viewTile addGestureRecognizer:tapT];
        
        viewTile.isTilesBelongsToScrollView=YES;
        
        if ([opponent_ID isEqualToString:strUserId])
        {
            viewTile.isLowerScrollWord=YES;
            viewTile.isUpparScrollWord=NO;
          //  viewTile.my_TAG=arrUserALLWords.count+100;
        }
        else
        {
            viewTile.isLowerScrollWord=NO;
            viewTile.isUpparScrollWord=YES;
          //  viewTile.my_TAG=arrOpponentAllWord.count+1000;
        }
        
        
        [view addSubview:viewTile];
        
    }

    
    
    view.strWordString=[self returnTheWordStringForBaseView:arrayChars];
    view.wordScore=scoreToIncrease;
    
    if ([opponent_ID isEqualToString:strUserId])
    {
          [arrUserALLWords addObject:view];
         [self arrangeUserScrollviewAfterWordCompeltion];
        
        [arrSelectedCharachtars removeAllObjects];
        [arrStealedCharsMainArray removeAllObjects];
        [arrStealCharsTemparray removeAllObjects];

    }
    else
    {
         [arrOpponentAllWord addObject:view];
        [self arrangeOppponentScrollviewAfterWordCompeltion];
        
        
        for (TileView *tV in arrayViewsToRemoved) {
            
            if ([tV isKindOfClass:[TileView class]]) {
                
                if ([arrSelectedCharachtars containsObject:tV]) {
                    [arrSelectedCharachtars removeObject:tV];
                }
                if ([arrStealCharsTemparray containsObject:tV]) {
                    [arrStealCharsTemparray removeObject:tV];
                }
                if ([arrStealedCharsMainArray containsObject:tV]) {
                    [arrStealedCharsMainArray removeObject:tV];
                }
                
            }
            
        }

        [self fillTheTilesInUserBoxAfterSelected];
        
     }
 
    [self removAllViewAfterARightAnswer:arrayViewsToRemoved];
   
}


// get Random Frames

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



-(NSString*)returnTheWordStringForBaseView:(NSMutableArray*)arrChars
{
    NSString *strWord=@"";
   
    for (NSDictionary *dict in arrChars) {
     
        if ([dict isKindOfClass:[NSDictionary class]]) {
        
            strWord=[strWord stringByAppendingString:[dict objectForKey:@"char"]];
        }
        
    }
    
     return strWord;
}







#pragma mark xmpp subjects sent

-(void)sendGameQuittedPacket
{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:[self.dictMain objectForKey:@"game_id"] forKey:@"game_id"];
    
     NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:Game_Quit_User Body:myString withID:strMessageID];
    

}


-(void)sendStackTapSubject:(NSDictionary*)dictChar
{

    stackTappedReceived=NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:[self.dictMain objectForKey:@"game_id"] forKey:@"game_id"];
    [dict setObject:[dictChar objectForKey:@"id"] forKey:@"character_id"];

    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:STACK_TAPPED Body:myString withID:strMessageID];

    
//    imgOnlineOrOff.image=[UIImage imageNamed:@"indicator_red"];
    btnStack.userInteractionEnabled=NO;
    
    
    [self changeUserStatus:NO];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    
    [self performSelector:@selector(shouldShowOnline) withObject:nil afterDelay:15.0];

}


-(void)sendWordSubmittedPacket
{

    
    if (![ObjApp_Delegate isXmppConnectedAndAuthenticated]) {
        return;
    }
    
    NSMutableArray *arrChars=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:[self.dictMain objectForKey:@"game_id"] forKey:@"game_id"];
    
    [dict setObject:@"N" forKey:@"isstealedword"];

    for (int i=0; i<arrSelectedCharachtars.count; i++)
    {
        TileView *t=[arrSelectedCharachtars objectAtIndex:i];
        [arrChars addObject:t.dictCharData];
    }
    
    
//    {"game_id":1,"word":"[{'id':1,'char':'A'},{'id':2,'char':'V'}]","user_id":32}
    

    [dict setObject:arrChars forKey:@"word"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:SUBMIT_WORD Body:myString withID:strMessageID];


}


-(void)sendWordSubmittedPacketInStealMode
{
    
    if (![ObjApp_Delegate isXmppConnectedAndAuthenticated]) {
        return;
    }
    
    NSMutableArray *arrChars=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:[self.dictMain objectForKey:@"game_id"] forKey:@"game_id"];
    
    [dict setObject:@"Y" forKey:@"isstealedword"];
    
    for (int i=0; i<arrStealedCharsMainArray.count; i++)
    {
        TileView *t=[arrStealedCharsMainArray objectAtIndex:i];
        [arrChars addObject:t.dictCharData];
    }
    

    NSMutableDictionary *dictWordTobeRemoved=[[NSMutableDictionary alloc]init];
    
    
    if (refViewForSteal_Opponent) {
        
        NSMutableDictionary *dictOpWord=[[NSMutableDictionary alloc]init];

         NSString* strOWord=refViewForSteal_Opponent.strWordString;
        
        if (strOWord)
        {
             [dictOpWord setObject:strOWord forKey:@"word"];
            
             NSInteger score=strOWord.length-2;
             [dictOpWord setObject:[NSString stringWithFormat:@"%ld",(long)score] forKey:@"score"];
             [dictWordTobeRemoved setObject:dictOpWord forKey:@"opponent_word"];
        }
     }
    else
    {
        [dictWordTobeRemoved setObject:@"" forKey:@"opponent_word"];
    }
 
    if (refViewForSteal_User) {
        NSMutableDictionary *dictUserWord=[[NSMutableDictionary alloc]init];
          NSString* strOWord=refViewForSteal_User.strWordString;
         if (strOWord)
         {
            [dictUserWord setObject:strOWord forKey:@"word"];
             NSInteger score=strOWord.length-2;

            [dictUserWord setObject:[NSString stringWithFormat:@"%ld",(long)score] forKey:@"score"];
            [dictWordTobeRemoved setObject:dictUserWord forKey:@"my_word"];
          }
     }
    else
    {
        [dictWordTobeRemoved setObject:@"" forKey:@"my_word"];
    }
    
     [dict setObject:dictWordTobeRemoved forKey:@"word_remove"];
     [dict setObject:arrChars forKey:@"word"];
    

    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:SUBMIT_WORD Body:myString withID:strMessageID];
    
    
}





#pragma mark  Xmpp responses received in Several Subjects
-(void)stackTapped:(NSNotification*)notification
{
    
    
    NSDictionary *dict=notification.object;
    if (!stackTappedReceived)
    {
        stackTappedReceived=YES;
        if ([[dict objectForKey:@"wasDelayed"]isEqualToString:@"NO"]) {
            [self changeUserStatus:YES];
        }
    }
    NSLog(@"Stack Tapped Notification came");
    dict=[dict objectForKey:@"stack_tap"];
    NSMutableDictionary *dictChars=[[NSMutableDictionary alloc]init];
    [dictChars setObject:[dict objectForKey:@"character_value"] forKey:@"char"];
    [dictChars setObject:[dict objectForKey:@"character_id"] forKey:@"id"];
    /*
    if ([arrShuffledArray containsObject:dictChars]) {
        [arrShuffledArray removeObject:dictChars];
         NSLog(@"Character removed from the main array");
    }
    */
    if ([arrWovelsArray containsObject:dictChars]) {
        [arrWovelsArray removeObject:dictChars];
        NSLog(@"vowel removed from the array %@",dictChars);
    }
    else if ([arrConsonatsArray containsObject:dictChars])
    {
        [arrConsonatsArray removeObject:dictChars];
        NSLog(@"consonant removed from the array %@",dictChars);
    }
    [self addTilesInPoolForOpponentTapped:dictChars];
}

-(void)submitWord:(NSNotification*)notification
{
    
}

-(void)wordCompleted:(NSNotification*)notification
{
    btnSubmit.userInteractionEnabled=YES;
    NSDictionary *dict=notification.object;
   
    NSString *str=[dict objectForKey:@"isstealedword"];
    
    
    if ([str isEqualToString:@"Y"])
    {
        
        if ([[dict objectForKey:@"status"]integerValue]==1)
        {
            NSMutableArray *arr=[dict objectForKey:@"word"];
            NSMutableArray *arrViewToremove=[[NSMutableArray alloc]init];
            NSMutableArray *arrCharachtersToRemove=[[NSMutableArray alloc]init];
            
            for (int i=0; i<arr.count; i++)
            {
                NSDictionary *dict=[arr objectAtIndex:i];
                
                
                for (int j=0; j<arrCurrentTilesInPOOL.count; j++)
                {
                    
                    TileView *vw=[arrCurrentTilesInPOOL objectAtIndex:j];
 
                    
                    if ([[dict objectForKey:@"id"]integerValue]==[[vw.dictCharData objectForKey:@"id"] integerValue])
                    {
                        [arrViewToremove addObject:vw];
//                        [arrCharachtersToRemove addObject:dict];
                    }
                }
             }
            
            
            arrCharachtersToRemove=arr;
             scoreToIncrease=0;
             scoreToIncrease=[[dict objectForKey:@"score"]intValue];
//           [self addWordsInUsersAllwordsScrollView:arrViewToremove arrChars:arrCharachtersToRemove O_id:[dict objectForKey:@"created_by"]];
            [self addWordsInUsersAllwordsScrollViewForStealMode:arrViewToremove arrChars:arrCharachtersToRemove word_createdBy:[dict objectForKey:@"created_by"]info:[dict objectForKey:@"word_remove"]];

            
            NSString *strUserId=App_Delegate.currentUser.userID;

            if ([strUserId isEqualToString:[dict objectForKey:@"user_id"]]) {
                
                lblGameOponentScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"opponent_score"]];
                lblGameOwnerScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"score"]];
                
                gameOwnerScore=[[dict objectForKey:@"score"] intValue];
                gameOpponentScore=[[dict objectForKey:@"opponent_score"] intValue];
                [self playGameSounds:wordSUbmitSound];

             }
            else
            {
                lblGameOponentScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"score"]];
                lblGameOwnerScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"opponent_score"]];
         
                gameOpponentScore=[[dict objectForKey:@"score"] intValue];
                gameOwnerScore=[[dict objectForKey:@"opponent_score"] intValue];

            }
            
        }
        else
        {
            
            NSString *createdByID=[dict objectForKey:@"created_by"];
            NSString *strUserId=App_Delegate.currentUser.userID;
            if ([createdByID isEqualToString:strUserId])
            {
//                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];

                [arrSelectedCharachtars removeAllObjects];
                [arrStealCharsTemparray removeAllObjects];
                [arrStealedCharsMainArray removeAllObjects];
                [self fillTheTilesInUserBoxAfterSelected];
                isStealModeOn=NO;
                
                [self playGameSounds:wordWrongSound];
 
            }
        }

        
    }
   
   else
   {
        
        if ([[dict objectForKey:@"status"]integerValue]==1)
        {
            NSMutableArray *arr=[dict objectForKey:@"word"];
            NSMutableArray *arrViewToremove=[[NSMutableArray alloc]init];
            NSMutableArray *arrCharachtersToRemove=[[NSMutableArray alloc]init];
            
            for (int i=0; i<arr.count; i++)
            {
                NSDictionary *dict=[arr objectAtIndex:i];
                
                
                for (int j=0; j<arrCurrentTilesInPOOL.count; j++)
                {
                    
                    TileView *vw=[arrCurrentTilesInPOOL objectAtIndex:j];
                    
                    if ([[dict objectForKey:@"id"]integerValue]==[[vw.dictCharData objectForKey:@"id"] integerValue])
                    {
                        [arrViewToremove addObject:vw];
                       // [arrCharachtersToRemove addObject:dict];
                    }
                }
                
            }
            arrCharachtersToRemove=arr;
            scoreToIncrease=0;
            scoreToIncrease=[[dict objectForKey:@"score"]intValue];
            [self addWordsInUsersAllwordsScrollView:arrViewToremove arrChars:arrCharachtersToRemove O_id:[dict objectForKey:@"created_by"]];
            
            NSString *strUserId=App_Delegate.currentUser.userID;
            
            if ([strUserId isEqualToString:[dict objectForKey:@"user_id"]]) {
                
                lblGameOponentScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"opponent_score"]];
                lblGameOwnerScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"score"]];
                
                gameOwnerScore=[[dict objectForKey:@"score"] intValue];
                gameOpponentScore=[[dict objectForKey:@"opponent_score"] intValue];
                
                [self playGameSounds:wordSUbmitSound];


            }
            else
            {
                lblGameOponentScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"score"]];
                lblGameOwnerScore.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"opponent_score"]];
                
                gameOpponentScore=[[dict objectForKey:@"score"] intValue];
                gameOwnerScore=[[dict objectForKey:@"opponent_score"] intValue];

            }

        }
        else
        {
            NSString *createdByID=[dict objectForKey:@"created_by"];
            NSString *strUserId=App_Delegate.currentUser.userID;
            if ([createdByID isEqualToString:strUserId])
            {
                 [self setAllTilesBackIfAnswerIsWrong];

            }
        }

    }
    
}

-(void)submitWordError:(NSNotification*)notification
{
    
}

-(void)gameResult:(NSNotification*)notification
{
    
}

-(void)playerWon:(NSNotification*)notification
{
    
}

-(void)gameTimedOut:(NSNotification*)notification
{
    
}


-(void)gameQuitted
{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your Opponent Left the game. You win." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    alert.tag=101;
    [alert show];

}


//For Check Xmpp successfully connected
-(void)xmppConnectedSuccessfully
{
    
    
    UIAlertController *alertAuto = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Connected to server"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertAuto animated:YES completion:nil];
    int duration = 1.5; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alertAuto dismissViewControllerAnimated:YES completion:nil];
    });
    
    [vwConnectionLost removeFromSuperview];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tryingtoconnect) object:nil];
    
    isConnectedToXmpp=YES;
    
   // UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Connected to server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
    
    

}

-(void)xmppDisconnected
{
    
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Connection Lost" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
    [vwConnectionLost removeFromSuperview];
    vwConnectionLost.frame=self.view.frame;
    [self.view addSubview:vwConnectionLost];
    
    isConnectedToXmpp=NO;

    if (!isTryingToConnect)
    {
        isTryingToConnect=YES;
        //If not connected try to connect
        [self performSelector:@selector(tryingtoconnect) withObject:nil afterDelay:8.0];
    }
 }

-(void)tryingtoconnect
{
    isTryingToConnect=NO;
    
    if (!isConnectedToXmpp)
    {
        [App_Delegate tryToConnectWithXmppInBG];
     }
}




-(void)changeUserStatus:(BOOL)isOnline
{
    imgOnlineOrOff.hidden=YES;
    imgOnlineOrOffOpponent.hidden=YES;
    
    btnOpponentStatus.selected=NO;
    btnUserStatus.selected=NO;
    imgHand.hidden=YES;
    
    if (isOnline)
    {
        btnStack.userInteractionEnabled=YES;
        lbl15Sec.text=@"10";
        counter15sec=turnFinishedSeconds;
        [timer15Sec invalidate];
        timer15Sec=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeandStatusImage) userInfo:nil repeats:YES];
        imgStatusIndicator.image=[UIImage imageNamed:@"img_circle_green"];
        
        progressCircle.gaugeTintColor = green;
        [progressCircle setValue:1.0 animated:NO];

        shouldShowUserOnline=YES;
    }
    else
    {
        btnStack.userInteractionEnabled=NO;
        imgStatusIndicator.image=[UIImage imageNamed:@"img_circle_green"];
        progressCircle.gaugeTintColor = green;
        [progressCircle setValue:1.0 animated:NO];

        lbl15Sec.text=@"10";
        counter15sec=turnFinishedSeconds;
        [timer15Sec invalidate];
        timer15Sec=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeandStatusImage) userInfo:nil repeats:YES];
        shouldShowUserOnline=NO;
    }
    if (isOnline) {
        
        
         imgOnlineOrOff.hidden=NO;
         imgOnlineOrOffOpponent.hidden=YES;
        
        btnUserStatus.selected=NO;
        btnOpponentStatus.selected=YES;
        
        imgHand.hidden=NO;

    }
    else
    {
        imgOnlineOrOff.hidden=YES;
        imgOnlineOrOffOpponent.hidden=NO;
        
        btnUserStatus.selected=YES;
        btnOpponentStatus.selected=NO;

        imgHand.hidden=YES;

    }
}
-(void)shouldShowOnline
{
    if (!shouldShowUserOnline)
    {
        [self changeUserStatus:YES];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==101)
    {
        [self gotoHome];
    }
}


-(IBAction)gotoHome
{
    [self removeAllObservers];
    HomeVC *vc=[[HomeVC alloc]init];
    [App_Delegate changeRootVieController:vc];
    
}


#pragma mark Steel Mode Methods
 
#pragma mark stealMode Case first  =>  users own word + one word from pool

// this method will disables the other word in steal mode. only the current word will be able to Steal


#pragma mark stealMode Case second => users own word + opponent one word + one char from pool



#pragma mark stealMode Case third  =>  users own word + opponent one word


-(void)tileSelectedForStealing:(UITapGestureRecognizer*)tap
{
    
   [self playGameSounds:stackTapSound];
    TileView *tView=(TileView*)tap.view;
    tView.lblT.textColor=[UIColor whiteColor];

     if ([tView isKindOfClass:[TileView class]])
    {
        if (tView.isSelected==NO)
        {
            tView.isSelected=YES;
            [arrStealedCharsMainArray addObject:tView];
            [arrStealCharsTemparray addObject:tView];
            [self fillTheTilesInUserBoxAfterSelected];
        }
        else
        {
             tView.isSelected=NO;
            [arrStealedCharsMainArray removeObject:tView];
            [arrStealCharsTemparray removeObject:tView];
            [self addTileViewBackToPoolForStealMode:tView];
        }
    }
    
    if (arrStealCharsTemparray.count>0)
    {
        isStealModeOn=YES;
        [self disableAllViewInScrollViewWhenStealingFromOneViewIsOn:tView];
        
        BOOL isUpparScrollWord=NO;
        BOOL isLowerScrollWord=NO;
        
        for (int i=0; i<arrStealedCharsMainArray.count; i++) {
            
            TileView *t=[arrStealedCharsMainArray objectAtIndex:i];
             if (t.isUpparScrollWord) {
                
                isUpparScrollWord=YES;
            }
            
            else if (t.isLowerScrollWord) {
                
                isLowerScrollWord=YES;
            }
        }
       
        if (!isLowerScrollWord) {
            for (BaseViewForTiles *viewBase in scrlUser2.subviews) {
                
                if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                    viewBase.userInteractionEnabled=YES;
                }
            }

            refViewForSteal_User=nil;
        }
        if (!isUpparScrollWord) {
            for (BaseViewForTiles *viewBase in scrlUser1.subviews) {
                
                if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                    viewBase.userInteractionEnabled=YES;
                }
            }
            refViewForSteal_Opponent=nil;

        }
        
    }
    else
    {
        isStealModeOn=NO;
        [self enableAllViewInScrollViewWhenStealing];
        
        refViewForSteal_User=nil;
        refViewForSteal_Opponent=nil;

    }

}

// this method will enable all views in both scroll views


-(void)disableAllViewInScrollViewWhenStealingFromOneViewIsOn:(TileView*)tVIew
{
    NSInteger tag=tVIew.my_TAG;
    BaseViewForTiles *superViewOfTileUSer,*superViewOfTileOpponent;

    //if tag is greater then 1000 then it means this tile is stolen from opponent user view
    if (tag>=1000)
    {
        superViewOfTileOpponent=(BaseViewForTiles*)[scrlUser1 viewWithTag:tag];
        
        for (BaseViewForTiles *viewBase in scrlUser1.subviews) {
            
            if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                viewBase.userInteractionEnabled=NO;
            }
        }
         superViewOfTileOpponent.userInteractionEnabled=YES;
         refViewForSteal_Opponent=superViewOfTileOpponent;

    }
    else
    {
        superViewOfTileUSer=(BaseViewForTiles*)[scrlUser2 viewWithTag:tag];
        
        for (BaseViewForTiles *viewBase in scrlUser2.subviews) {
            
            if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                viewBase.userInteractionEnabled=NO;
            }
        }

        superViewOfTileUSer.userInteractionEnabled=YES;
        refViewForSteal_User=superViewOfTileUSer;
    }
    

}

// this method will enable all views in both scroll views
-(void)enableAllViewInScrollViewWhenStealing
{
    
    //if tag is greater then 1000 then it means this tile is stolen from opponent user view
    
        for (BaseViewForTiles *viewBase in scrlUser1.subviews) {
            
            if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                viewBase.userInteractionEnabled=YES;
            }
        }
         for (BaseViewForTiles *viewBase in scrlUser2.subviews) {
            
            if ([viewBase isKindOfClass:[BaseViewForTiles class]]) {
                viewBase.userInteractionEnabled=YES;
            }
        }
    
}


-(void)fillTheTilesInUserBoxAfterSelected
{
    
    // if there is any charachters available in BOX then remove it before adding new one
    for (TileView *tV in vwUserWordBox.subviews) {
        
        if ([tV isKindOfClass:[TileView class]]) {
            [tV removeFromSuperview];
        }
    }
    
    
    // now add the all view back in BOXView from the selectedcharacters array
    
    BOOL isUpparScrollWord=NO;
    BOOL isLowerScrollWord=NO;
    
    for (int i=0; i<arrStealedCharsMainArray.count; i++) {
        
        TileView *t=[arrStealedCharsMainArray objectAtIndex:i];
        t.frame=CGRectMake(i*labelwidthAndheight, 0, labelwidthAndheight, labelwidthAndheight);
        [vwUserWordBox addSubview:t];
        
        if (t.isUpparScrollWord) {
            
            isUpparScrollWord=YES;
        }
        
        else if (t.isLowerScrollWord) {
            
            isLowerScrollWord=YES;
        }
    }
    
     
    if (!isLowerScrollWord) {
        
        refViewForSteal_User=nil;
        
    }
    
    if (!isUpparScrollWord) {
        
        refViewForSteal_Opponent=nil;
     }
}



-(void)addTileViewBackToPoolForStealMode:(TileView*)tVIew
{
    tVIew.layer.borderColor=[UIColor clearColor].CGColor;
    tVIew.layer.borderWidth=1.0;
    
    NSInteger tag=tVIew.my_TAG;
    
    BaseViewForTiles *superViewOfTile;
    
    //if tag is greater then 1000 then it means this tile is stolen from opponent user view
    if (tag>=1000)
    {
        superViewOfTile=(BaseViewForTiles*)[scrlUser1 viewWithTag:tag];
    }
    else
    {
        superViewOfTile=(BaseViewForTiles*)[scrlUser2 viewWithTag:tag];
        
    }
    
    CGRect rect=CGRectZero;
    rect =[[tVIew.dictTileFrame objectForKey:@"frame"] CGRectValue];
    tVIew.frame=rect;

    
    //if tile is taken from the scrollview then it will be place back to scrollview and if tile is taken from pool then it will be set back to pool
    if (tVIew.isTilesBelongsToScrollView ) {

        [superViewOfTile addSubview:tVIew];
     }
   else
   {
       [self.view addSubview:tVIew];

   }
    
    //arrange the order back to latest word after removing any new word from here.
    [self fillTheTilesInUserBoxAfterSelected];
}



-(void)setAllTilesBackToTheirCorrespondingPlaces
{
    
}



-(void)addWordsInUsersAllwordsScrollViewForStealMode:(NSMutableArray*)arrayViews   arrChars:(NSMutableArray*)arrayChars   word_createdBy:(NSString*)ID  info:(NSDictionary*)dictInfo
{
//    NSMutableArray *arrViews=[[NSMutableArray alloc]init];opponent_word
    
    
    NSDictionary *dictM=[dictInfo objectForKey:@"my_word"];
    
    NSDictionary *dictO=[dictInfo objectForKey:@"opponent_word"];

    [self checkIfStealedWordExitsinBothWordsArray:dictM dicOp:dictO word_createdBy:ID];
    
    NSString *strUserId=App_Delegate.currentUser.userID;

    BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrayChars.count, labelwidthAndheight)];
    
    for (int i=0; i<arrayChars.count; i++)
    {
        
        NSMutableDictionary *dict=[arrayChars objectAtIndex:i];
        
        UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
        tapT.numberOfTapsRequired = 1;
        tapT.delegate=self;
        
        
        TileView *viewTile=[TileView initWithFrame:CGRectMake(i*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
        viewTile.lblT.text= [dict objectForKey:@"char"];
        viewTile.userInteractionEnabled=YES;
        viewTile.dictCharData=dict;
        NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
        [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
        viewTile.dictTileFrame=dictF;
        [viewTile addGestureRecognizer:tapT];

        viewTile.isTilesBelongsToScrollView=YES;

        if ([ID isEqualToString:strUserId])
        {
            viewTile.isLowerScrollWord=YES;
            viewTile.isUpparScrollWord=NO;
        }
        else
        {
            viewTile.isLowerScrollWord=NO;
            viewTile.isUpparScrollWord=YES;
        }
        [view addSubview:viewTile];
     }
    
    
    view.strWordString=[self returnTheWordStringForBaseView:arrayChars];
    view.wordScore=scoreToIncrease;

    
    if ([ID isEqualToString:strUserId])
    {
        //  view.tag=arrUserALLWords.count+100;
          [arrUserALLWords addObject:view];

        
//          gameOwnerScore=gameOwnerScore+scoreToIncrease;
//          lblGameOwnerScore.text=[NSString stringWithFormat:@"Score: %d",gameOwnerScore];
        
          [self arrangeUserScrollviewAfterWordCompeltion];
          [arrSelectedCharachtars removeAllObjects];
          [arrStealCharsTemparray removeAllObjects];
          [arrStealedCharsMainArray removeAllObjects];
          isStealModeOn=NO;
          [self enableAllViewInScrollViewWhenStealing];
    }
    else
    {
     //   view.tag=arrOpponentAllWord.count+1000;
        [arrOpponentAllWord addObject:view];
//        gameOpponentScore=gameOpponentScore+scoreToIncrease;
//        lblGameOponentScore.text=[NSString stringWithFormat:@"Score: %d",gameOpponentScore];
        [self arrangeOppponentScrollviewAfterWordCompeltion];
        
        
        
        for (TileView *tV in arrayViews) {
            
            if ([tV isKindOfClass:[TileView class]]) {
                
                if ([arrSelectedCharachtars containsObject:tV]) {
                    [arrSelectedCharachtars removeObject:tV];
                }
                if ([arrStealCharsTemparray containsObject:tV]) {
                    [arrStealCharsTemparray removeObject:tV];
                }
                if ([arrStealedCharsMainArray containsObject:tV]) {
                    [arrStealedCharsMainArray removeObject:tV];
                }

            }
        }
        
        
        for (int i=0; i<arrayChars.count; i++)
        {
            NSDictionary *dict=[arrayChars objectAtIndex:i];
             for (int j=0; j<arrStealedCharsMainArray.count; j++)
            {
                 TileView *vw=[arrStealedCharsMainArray objectAtIndex:j];
                 if ([[dict objectForKey:@"id"]integerValue]==[[vw.dictCharData objectForKey:@"id"] integerValue])
                {
                    [arrSelectedCharachtars removeObject:vw];
                    [arrStealCharsTemparray removeObject:vw];
                    [arrStealedCharsMainArray removeObject:vw];
                 }
            }
        }

        
        [self fillTheTilesInUserBoxAfterSelected];
        refViewForSteal_Opponent=nil;
        refViewForSteal_User=nil;

    }
    
    
 
    for (int i=0; i<arrayViews.count; i++)
    {
        TileView *tl=[arrayViews objectAtIndex:i];
         if ([arrCurrentTilesInPOOL containsObject:tl])
         {
             [arrCurrentTilesInPOOL removeObject:tl];
             [tl.dictTileFrame setObject:@"0" forKey:@"isUsed"];
             [tl removeFromSuperview];

        }
     }
    
    
    

    
    for (TileView *tV in vwUserWordBox.subviews) {
        
        if ([tV isKindOfClass:[TileView class]]) {
            [tV removeFromSuperview];
        }
    }

    
 //[self removAllViewAfterARightAnswer:arrayViews];
    
}




-(void)checkIfStealedWordExitsinBothWordsArray:(NSDictionary*)dictMyWord dicOp:(NSDictionary*)dictOponent  word_createdBy:(NSString*)ID
{

    NSString *strword1=@"";
    NSString *strword2=@"";
    
    int scoreO=0;
    int scoreU=0;
    
    if ([dictMyWord isKindOfClass:[NSDictionary class]]) {
        strword1=[dictMyWord objectForKey:@"word"];
        scoreU=[[dictMyWord objectForKey:@"score"]intValue];

     }
    
    if ([dictOponent isKindOfClass:[NSDictionary class]]) {
        strword2=[dictOponent objectForKey:@"word"];
        scoreO=[[dictOponent objectForKey:@"score"]intValue];

    }

     
    
    BaseViewForTiles *tempBaseOp=nil;
    
    for (BaseViewForTiles *baseV in arrOpponentAllWord) {
        
        NSLog(@"opponent word %@",baseV.strWordString);
        
        if ([baseV.strWordString isEqualToString:strword1]||[baseV.strWordString isEqualToString:strword2]) {
            
            tempBaseOp=baseV;
        }
       }
    
    // decrease the score of opponent if the word is successfully stealed and also remove this word from the opponents all word array
    if (tempBaseOp)
    {
          [arrOpponentAllWord removeObject:tempBaseOp];
          [self arrangeOppponentScrollviewAfterWordCompeltion];
    }
 
    
    BaseViewForTiles *tempBaseUser=nil;

    
    for (BaseViewForTiles *baseV in arrUserALLWords) {

        NSLog(@"user word %@",baseV.strWordString);

        if ([baseV.strWordString isEqualToString:strword1]||[baseV.strWordString isEqualToString:strword2]) {
            
            tempBaseUser=baseV;
        }
    }
    
     if (tempBaseUser)
    {
        [arrUserALLWords removeObject:tempBaseUser];
        [self arrangeUserScrollviewAfterWordCompeltion];

    }

    NSString *strUserId=App_Delegate.currentUser.userID;

    if ([ID isEqualToString:strUserId])
    {
 
    }
    else
    {
 
 
    }
    
    
    
}





-(void)arrangeUserScrollviewAfterWordCompeltion
{
    for (BaseViewForTiles *view in scrlUser2.subviews)
    {
        if ([view isKindOfClass:[BaseViewForTiles class]]) {
            [view removeFromSuperview];
        }
    }

    
    int yValue=0;
    int currentWidth=0;
    for (int i=0; i<arrUserALLWords.count; i++)
    {
        
        BaseViewForTiles *vT=[arrUserALLWords objectAtIndex:i];
        int viewArea= (int)(vT.strWordString.length*labelwidthAndheight)+5;
        int remainingArea=scrlUser1.frame.size.width-currentWidth;
        
        if (remainingArea>viewArea)
        {
            vT.frame =CGRectMake(currentWidth,yValue*labelwidthAndheight,vT.frame.size.width, labelwidthAndheight);
            currentWidth=currentWidth+viewArea;
            
        }
        else
        {
            currentWidth=0;
            yValue++;
            vT.frame =CGRectMake(0,yValue*labelwidthAndheight,vT.frame.size.width, labelwidthAndheight);
            currentWidth=currentWidth+viewArea;
         }
        
        vT.tag=i+100;
        
        for (TileView *t in vT.subviews) {
            
            if ([t isKindOfClass:[TileView class]]) {
             
                t.my_TAG=vT.tag;
                
            }
        }

        [scrlUser2 addSubview:vT];
    }

    /*
    
    for (int i=0; i<arrUserALLWords.count; i++) {
        
        BaseViewForTiles *vT=[arrUserALLWords objectAtIndex:i];

        vT.frame =CGRectMake(0,i*labelwidthAndheight,vT.frame.size.width, labelwidthAndheight);
        [scrlUser2 addSubview:vT];
    }*/
    
    scrlUser2.contentSize=CGSizeMake(scrlUser2.frame.size.width, (yValue+1)*labelwidthAndheight);
}


// This method will handle the all words which are correct and will show them in user scrollviews
-(void)arrangeOppponentScrollviewAfterWordCompeltion
{
    for (BaseViewForTiles *view in scrlUser1.subviews)
    {
        
        if ([view isKindOfClass:[BaseViewForTiles class]]) {
            [view removeFromSuperview];
        }
    }
 
    int yValue=0;
    int currentWidth=0;
    for (int i=0; i<arrOpponentAllWord.count; i++) {
        
        BaseViewForTiles *vT=[arrOpponentAllWord objectAtIndex:i];
        int viewArea= (int)(vT.strWordString.length*labelwidthAndheight)+5;
        int remainingArea=scrlUser1.frame.size.width-currentWidth;

        if (remainingArea>viewArea)
        {
             vT.frame =CGRectMake(currentWidth,yValue*labelwidthAndheight,vT.frame.size.width, labelwidthAndheight);
            currentWidth=currentWidth+viewArea;

        }
        else
        {
            currentWidth=0;
            yValue++;
            vT.frame =CGRectMake(0,yValue*labelwidthAndheight,vT.frame.size.width, labelwidthAndheight);
            
            currentWidth=currentWidth+viewArea;

        }

        vT.tag=i+1000;

        for (TileView *t in vT.subviews) {
            
            if ([t isKindOfClass:[TileView class]]) {
                t.my_TAG=vT.tag;

            }
        }
        
        [scrlUser1 addSubview:vT];
    }

    scrlUser1.contentSize=CGSizeMake(scrlUser1.frame.size.width, (yValue+1)*labelwidthAndheight);

}






#pragma autosuggest new method

#pragma mark Suggest Meaningful words from the pool

-(IBAction)suggestedWords
{
    
    
    
    if ([[Anagrams_Defaults objectForKey:kIsUnlimitedCrownsAdded] isEqualToString:@"YES"])
    {
        
    }
    else{
        
        NSInteger crowns=[Anagrams_Defaults integerForKey:kNumberOfCrowns];
         if (crowns<5) {
             
//            [[[UIAlertView alloc]initWithTitle:appname message:@"You have insufficient coins to guess the word" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
             
             [self setAllTilesBackIfAnswerIsWrong];

            return;
        }

    }
    
    
    
    if (arrCurrentTilesInPOOL.count<3) {
        
        [self setAllTilesBackIfAnswerIsWrong];

//        [[[UIAlertView alloc]initWithTitle:appname message:@"Word length must be greater than equal to three characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
        return;
    }

    
    
    [MBProgressHUD showHUDAddedTo:ObjApp_Delegate.window animated:YES];
    
     if (threadwordSuggest) {
         [threadwordSuggest cancel];
    }
   threadwordSuggest= [[NSThread alloc]initWithTarget:self selector:@selector(getMeaningfulWordhere) object:nil];
    [threadwordSuggest start];
    
}




-(void)getMeaningfulWordhere
{
    //    BOOL ifWordFound=NO;
    
    NSMutableArray *arrChars=[[NSMutableArray alloc]init];
    for (int i=0; i<arrCurrentTilesInPOOL.count; i++)
    {
        TileView *tvc=[arrCurrentTilesInPOOL objectAtIndex:i];
        [arrChars addObject:tvc.lblT.text];
        
    }
    
    
    NSString *word = [arrChars componentsJoinedByString:@""];
    
    
    
    suggestedWord=[self returnSuggestedWord:word];
    
    if (suggestedWord.length>0)
    {
        iswordFoundForSuggestion=YES;
    }
    else
    {
        iswordFoundForSuggestion=NO;
    }
    
    
    
    dispatch_async( dispatch_get_main_queue(), ^
                   {
                        if (iswordFoundForSuggestion)
                       {
                           
                           [MBProgressHUD hideAllHUDsForView:ObjApp_Delegate.window animated:YES];
                           
                           [self highLightTheWordinPOOL];
 
                           //   [self highLightTheWordinPOOL];
                       }
                       else
                       {
                           [MBProgressHUD hideAllHUDsForView:ObjApp_Delegate.window animated:YES];

                           UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Sorry! We could not found any word" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                           [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                           
                       }

                   });

    
    
    
    
    
}




-(void)highLightTheWordinPOOL
{
    
    [threadwordSuggest cancel];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    for (int i = 0; i < [suggestedWord length]; i++)
    {
        NSString *ch = [suggestedWord substringWithRange:NSMakeRange(i, 1)];
        [arrTemp addObject:ch];
    }
    
    
    for (int i=0; i<arrCurrentTilesInPOOL.count; i++)
    {
        
        TileView *t=[arrCurrentTilesInPOOL objectAtIndex:i];
        
        NSLog(@"Tile text is %@ and dictionary is %@",t.lblT.text,t.dictCharData);
        
        if ([arrTemp containsObject:t.lblT.text])
        {
//            t.layer.borderColor=[UIColor greenColor].CGColor;
//            t.layer.borderWidth=1.0;

            t.lblT.textColor=[UIColor greenColor];
            NSInteger index=[arrTemp indexOfObject:t.lblT.text];
            [arrTemp removeObjectAtIndex:index];
        }
        
    }
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Suggested Word" message:[NSString stringWithFormat:@"%@\n Meaning is :%@",suggestedWord,[Lexdictionary definitionFor:suggestedWord]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    
//     [alert show];

    
    
    [MBProgressHUD hideAllHUDsForView:ObjApp_Delegate.window animated:YES];
    
   
    NSInteger crowns=[Anagrams_Defaults integerForKey:kNumberOfCrowns];
    crowns=crowns-5;
    [Anagrams_Defaults setInteger:crowns forKey:kNumberOfCrowns];
    [Anagrams_Defaults synchronize];
    
}






-(NSString*)returnSuggestedWord:(NSString*)fromString
{
    suggestedWord=@"";
    arrWordsFound = [[NSMutableArray alloc] init];
    dictTempWordsToCheck =[[NSMutableDictionary alloc] init];
    
//     fromString = @"NODVNNIHVESZLTHBVHMSBRPSNHUWQENLICR";
    poolCharacterLength=(int)fromString.length;
    
  /*  if(poolCharacterLength >=16)
    {
        requiredWordLength = 7;
    }
    else if(poolCharacterLength >=10)
    {
        requiredWordLength = 6;
    }
    else*/  if(poolCharacterLength >=6)
    {
        requiredWordLength = 5;
    }
    else
    {
        requiredWordLength = 4;
    }

    [self permutation:fromString];
    if (suggestedWord.length == 0)
    {
        NSInteger maxLength = 0;
        if ([arrWordsFound count]>0)
        {
            for (NSString *strWord in arrWordsFound)
            {
                if (strWord.length>maxLength)
                {
                    maxLength = strWord.length;
                    suggestedWord = strWord;
                }
            }
        }
        NSLog(@"Required length word not found but we have another max word length word %@",suggestedWord);
    }
    
    NSLog(@"All words %@",[arrWordsFound description]);
    return suggestedWord;
}

-(void)permutation:(NSString *)str
{
    NSLog(@"Finding Hint for this String  %@",str);
    isWordFound=NO;
    [self permutation:@"" andString:str];
    
}
-(void)permutation:(NSString *)strPrefix andString:(NSString* )str
{
    if (isWordFound)
    {
        return;
    }
    NSInteger n = str.length;
  //  NSLog(@"*****************  %@",strPrefix);
    if ([strPrefix length]>=3)
    {
        if ([dictTempWordsToCheck objectForKey:[strPrefix substringWithRange:NSMakeRange(0, 3)]])
        {
            NSArray *arrTempWordsToCheck = [dictTempWordsToCheck objectForKey:[strPrefix substringWithRange:NSMakeRange(0, 3)]];
            BOOL isPrefixExist=false;
            if ([strPrefix.lowercaseString hasPrefix:@"tens"]) {
                NSLog(@"stop here pls");
            }
            for (int i=0; i<arrTempWordsToCheck.count; i++)
            {
                
                NSString *strWord=[arrTempWordsToCheck objectAtIndex:i];

                if ([strWord.lowercaseString isEqualToString:strPrefix.lowercaseString])
                {
                    [arrWordsFound addObject:strPrefix];
                    if (strPrefix.length>=requiredWordLength)
                    {
                        isWordFound = true;
                        suggestedWord=strPrefix;
                        iswordFoundForSuggestion=YES;
                         return;
                    }
                }
                if ([strWord.lowercaseString hasPrefix:strPrefix.lowercaseString])
                {
                    
                    isPrefixExist=true;
                    break;
                }
                
                
            }
            
            if (isPrefixExist==false)
            {
                //      NSLog(@"No more records for this preffix1 %@",strPrefix);
                return;
            }
            else
            {
                // NSLog(@"Prefix Found1 %@",strPrefix);
                
            }
            

        }
        else
        {
            if ([Lexdictionary containsDefinitionFor:strPrefix])
            {

             //   NSLog(@"Word Found %@ and meaning is ==>%@",strPrefix,[Lexdictionary definitionFor:strPrefix]);
                
                
                [arrWordsFound addObject:strPrefix];
                            if (strPrefix.length>=requiredWordLength)
                            {
                isWordFound = true;
                suggestedWord=strPrefix;
                iswordFoundForSuggestion=YES;
                
                return;
                           }
            }
            
            NSDictionary *arrWordsWithPrefix=[Lexdictionary wordsWithPrefix:strPrefix];
            if ([arrWordsWithPrefix count]>0)
            {
                NSMutableArray *arrTempWordsToCheck = [[NSMutableArray alloc] init];
                for (NSString *strKey in arrWordsWithPrefix.allKeys)
                {
                    
                    NSArray *arrWords=[arrWordsWithPrefix objectForKey:strKey];
                    
                    for (NSString *strKey2 in arrWords) {
                        
                        if (strKey2.length<=poolCharacterLength)
                        {
                            [arrTempWordsToCheck addObject:strKey2];
                        }
                    }
                    [dictTempWordsToCheck setObject:arrTempWordsToCheck forKey:[strPrefix substringWithRange:NSMakeRange(0, 3)]];
                }
                
             //   NSLog(@"Prefix Found2 %@",strPrefix);
                
                
            }
            else
            {
             //   NSLog(@"No more word now with this prefix2 %@",strPrefix);
                return;
            }

        }
    }
    if (n != 0)
    {
        for (int i = 0; i < n; i++)
        {
            
            if (isWordFound) {
                return;
            }

            [self permutation:[NSString stringWithFormat:@"%@%@",strPrefix,[str substringWithRange:NSMakeRange(i, 1)]] andString:[NSString stringWithFormat:@"%@%@",[str substringWithRange:NSMakeRange(0, i)],[str substringWithRange:NSMakeRange(i+1, n-(i+1))]]];
        }
    }
}


#pragma mark Rematch
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear Called");
    [self removeAllObservers];

}

-(void)dealloc
{
    [self removeAllObservers];
}

-(void)removeAllObservers
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [Anagrams_NotificationCenter removeObserver:self name:STACK_TAPPED object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:SUBMIT_WORD object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:WORD_COMPLETED object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:SUBMIT_WORD_ERROR object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:GAME_RESULT object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:GAME_TIMEOUT object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:Game_Quit_User object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:INVITATION_REJECTED object:nil];
    [Anagrams_NotificationCenter removeObserver:self];
    
    [timer15Sec invalidate];
    [timer4Minutes invalidate];
    timer4Minutes=nil;
    timer15Sec=nil;
    self.isOpponent=NO;
    self.dictMain=nil;
}


#pragma mark Rematch Functions and notifications

-(IBAction)btnRematchClicked:(id)sender
{
    [self sendInvitationToRematch];
}

-(void)sendInvitationToRematch
{
    
    
    NSMutableDictionary *dictRes=[[NSMutableDictionary alloc]init];
    
    NSString *strOpID=[self.dictMain objectForKey:@"opponent_id"];
    NSString *strUserID=[self.dictMain objectForKey:@"user_id"];
    
    [dictRes setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    
    if ([strOpID isEqualToString:ObjApp_Delegate.currentUser.userID]) {
        [dictRes setObject:[NSString stringWithFormat:@"%@",strUserID] forKey:@"opponent_id"];
    }
    else
    {
        [dictRes setObject:[NSString stringWithFormat:@"%@",[self.dictMain objectForKey:@"opponent_id"]] forKey:@"opponent_id"];
    }
    [dictRes setObject:@"" forKey:@"user_name"];
    [dictRes setObject:@"online" forKey:@"mode"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictRes options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [App_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:INVITE_USER Body:myString withID:strMessageID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
#pragma mark start Game Notification
-(void)startTheGameNow:(NSNotification*)notification
{

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary *dict=notification.object;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss Z";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSString *systDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *startTime=[dict objectForKey:@"starttime"];
    NSDate *date1=[dateFormatter dateFromString:systDate];
    NSDate *date2=[dateFormatter dateFromString:startTime];
    NSTimeInterval dely=[date2 timeIntervalSinceDate:date1];
    
    
    if (dely<10)
    {
        [self performSelector:@selector(GotoGamescreen:) withObject:dict afterDelay:dely];
    }
    else
    {
        [self performSelector:@selector(GotoGamescreen:) withObject:dict afterDelay:5];
    }

    NSLog(@"Response of Game Start Subject%@",dict);
    
}

-(void)GotoGamescreen:(NSDictionary*)dict
{
    App_Delegate.objGameOnline=(ViewController*)[App_Delegate getGameViewControllerObject:NO];
    App_Delegate.objGameOnline.dictMain=dict;
    [App_Delegate changeRootVieController:App_Delegate.objGameOnline];
}

-(void)invitationRejected
{
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Game Invitation Rejected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



#pragma mark Play Game Sounds

-(void)playGameSounds:(NSString*)type
{
    
    NSString *soundOn  =[Anagrams_Defaults objectForKey:isGameSoundOn];
    if ([soundOn isEqualToString:@"YES"]) {
        
        NSString *strFileName=@"";
        
        if ([type isEqualToString:stackTapSound]) {
            
            strFileName=@"Sounds/Stack_tap";
        }
        else if ([type isEqualToString:wordWrongSound])
        {
            strFileName=@"Sounds/WrongWord";
        }
        else if ([type isEqualToString:wordSUbmitSound])
        {
            // word submitted
            strFileName=@"Sounds/CorrectWord";
        }
        
        NSString *path = [[NSBundle mainBundle]pathForResource:strFileName ofType:@"wav"];
        
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        player.numberOfLoops=0;
        [player prepareToPlay];
        player.volume=1.0;
        [player play];

        
    }
    else
    {
        // don't play sound when it is off in setting;
    }
    
}


-(IBAction)shareOnFB
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    content.contentDescription=[NSString stringWithFormat:@"I beat my opponent in anagrams.io by %d points!",(gameOwnerScore-gameOpponentScore)];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.shareContent = content;
    
    dialog.mode=FBSDKShareDialogModeFeedWeb;
    dialog.delegate=self;
    if (![dialog canShow]) {
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    
    [dialog show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
 
    [ObjApp_Delegate showAlertView:@"" strMessage:@"Message shared on facebook successfully"];
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    
}

-(void)ShowOverlayTutorial
{
/*
    overly=[IOverlayView ViewWithFrame:self.view.frame];
    overly.delegate=self;
    
    overly.arrImages=[[NSMutableArray alloc]initWithObjects:@"tutorial_page9_overlay.png",@"tutorial_page10_overlay.png",@"tutorial_page11_overlay.png",@"tutorial_page12_overlay.png",@"tutorial_page13_overlay.png",@"tutorial_page14_overlay.png",@"tutorial_page15_overlay.png",@"tutorial_page16_overlay.png",@"tutorial_page17_overlay.png",@"tutorial_page18_overlay.png",@"tutorial_page19_overlay.png",@"tutorial_page20_overlay.png",@"tutorial_page21_overlay.png",@"tutorial_page22_overlay.png",@"tutorial_page23_overlay.png",@"tutorial_page24_overlay.png",@"tutorial_page25_overlay.png",nil];
    
    [ObjApp_Delegate.window addSubview:overly];
    */
    //[self performSelector:@selector(removeOverlayAutoMaticallyAfterOneMinute) withObject:nil afterDelay:60.0];
}



-(void)removeOverlayAutoMaticallyAfterOneMinute
{
    if (!isOverlyRemoved) {
        [overly removeFromSuperview];
        [self initializetheGameNotificationsAndVariables];
    }

}


-(void)didAllSlidesFinished:(UIView *)view
{
    isOverlyRemoved=YES;
    [view removeFromSuperview];
    [self initializetheGameNotificationsAndVariables];
}
@end
