//
//  OfflineGameVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 17/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "OfflineGameVC.h"
#import "HomeVC.h"
#import "ViewController.h"
#import "DraggableViewBackground.h"
#import "TileView.h"
#import "BeginVC.h"
#import "Lexicontext.h"
#import "JSON.h"

#define  lettersC          @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define  lettersConsonant  @"BCDFGHJKLMNPQRSTVWXYZ"
#define  lettersWovels     @"AEIOU"

#define stackTapSound          @"STACK_TAP"
#define wordSUbmitSound        @"WORD_SUBMIT"
#define wordWrongSound         @"WRONG_WORD"

#define labelwidthAndheight  30
#define xPosition  80
#define yPosition  200

#define gameTimeoutSeconds    180;  //500;//

#define turnFinishedSeconds   15;

@interface OfflineGameVC ()
@end


@implementation OfflineGameVC

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
    tilesRevealCounter=0;
    Lexdictionary =[Lexicontext sharedDictionary];
    
    
    arrSelectedCharachtars =[[NSMutableArray alloc]init];
    
//    self.navigationController.interactivePopGestureRecognizer.enabled=NO;
    
    if (self.isOpponent)
    {
        consonantCounter=2;
        
    }
    else
    {
    }
    
    counter15sec=turnFinishedSeconds;
    counter4Minutes=gameTimeoutSeconds;
    
    
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
    [Anagrams_NotificationCenter addObserver:self selector:@selector(gameTurnChangedPacketReceived) name:GAME_TURN_CHANGE object:nil];
    [Anagrams_NotificationCenter addObserver:self selector:@selector(startTheGameNow:) name:START_GAME object:nil];
    
    [Anagrams_NotificationCenter addObserver:self selector:@selector(userWonTheGame:) name:USER_TURNGAME_WON object:nil];

    [Anagrams_NotificationCenter addObserver:self selector:@selector(invitationRejected) name:INVITATION_REJECTED object:nil];

    [Anagrams_NotificationCenter addObserver:self selector:@selector(checkTurnIsValidOrNot:) name:TURN_CHECKER object:nil];

    arrALlCharactersMain=[self.dictMain objectForKey:@"character_stack"];
    NSString *strCurrentTurnUserID=[self.dictMain objectForKey:@"turn_user"];
    if (strCurrentTurnUserID&&strCurrentTurnUserID.length>0)
    {

        if ([strCurrentTurnUserID isEqualToString:ObjApp_Delegate.currentUser.userID]) {
            btnTurnChangeOppont.hidden=YES;
            btnTurnChangeUser.hidden=NO;
            btnStack.userInteractionEnabled=YES;
            btnUserStatus.selected=YES;
            btnOpponentStatus.selected=NO;
        }
        else
        {
            btnTurnChangeOppont.hidden=NO;
            btnTurnChangeUser.hidden=YES;
            btnStack.userInteractionEnabled=NO;
            btnUserStatus.selected=NO;
            btnOpponentStatus.selected=YES;
        }
    }
    else
    {
        btnTurnChangeOppont.hidden=YES;
        btnTurnChangeUser.hidden=NO;
        btnStack.userInteractionEnabled=YES;
        btnUserStatus.selected=YES;
        btnOpponentStatus.selected=NO;
    }
    

    arrCurrentTilesInPOOL     =  [[NSMutableArray alloc]init];
    arrStealedCharsMainArray  =  [[NSMutableArray alloc]init];
    arrStealCharsTemparray    =  [[NSMutableArray alloc]init];
    
    
    arrOpponentAllWord        =  [[NSMutableArray alloc]init];
    arrUserALLWords           =  [[NSMutableArray alloc]init];
    
    
     [self shuffleAnArray];
    
    
    arrHelpingVerb=[[NSMutableArray alloc]initWithObjects:@"am",@"are",@"is",@"was",@"were",@"be",@"being",@"been",@"have",@"has",@"had",@"shall",@"will",@"do",@"does",@"did",@"may",@"must",@"might",@"can",@"could",@"would",@"should",@"oughtto",@"having",@"and", nil];
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    gameId=[NSString stringWithFormat:@"%@",[self.dictMain objectForKey:@"game_id"]];
    app.currentGameId=gameId;
    
   // [self showGameWinningPopUp];
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





-(void)updateGameTimer
{
    counter4Minutes=counter4Minutes-1;
//    int seconds = counter4Minutes % 60;
   // int minutes = (counter4Minutes - seconds) / 60;

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
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Game Finished" message:@"You Loose" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=101;
            [alert show];
        }
        else if(gameOwnerScore>gameOpponentScore)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Game Finished" message:@"You Win" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=101;
            [alert show];
        }
        
        else if(gameOpponentScore==gameOwnerScore)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Game Finished" message:@"Game Tie" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=101;
            [alert show];
            
        }
     }
}




-(void)viewDidAppear:(BOOL)animated
{
    [self addFramesinArrayOfAllPool];
    
    [self setALLpageDataAccordingtoCurrentConditionofGame];

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
            [dict setObject:@"0" forKey:@"isUsed"];
            [arrRandomFrames addObject:dict];
        }
    }
    
    
    
}




-(IBAction)btnclced:(id)sender
{
    [self addTilesInPoolForCurrentUser];
}
-(NSDictionary *) randomStringWithLength
{
    
    
    
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
    
    
 
    if (tilesRevealCounter>3) {
        
        // this will automatically send the game turn change packet when the user have revealed 3 tiles
        return;
    }
    
    if (tilesRevealCounter==3) {
        
        [self sendGameTurnPacket];
    }

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
    //view.lblT.text=[self returnRandomString];
    
    [self.view addSubview:view];
    [view clipsToBounds];
    [view addGestureRecognizer:tap];
    [arrCurrentTilesInPOOL addObject:view];

    [self playGameSounds:stackTapSound];

    [UIView animateWithDuration:0.3 animations:^
     {
         view.frame=rectNewView;
         
     }completion:^(BOOL finished) {
         
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
    
    
    
    view.dictCharData=[dict mutableCopy];
    
    
    [self.view addSubview:view];
    [view clipsToBounds];
    [view addGestureRecognizer:tap];
    
    [arrCurrentTilesInPOOL addObject:view];
    
    [self playGameSounds:stackTapSound];

    [UIView animateWithDuration:0.3 animations:^
     {
         view.frame=rectNewView;
         
     }completion:^(BOOL finished) {
         

     }];
    
    
    
}





-(CGRect)getRandomFrame:(CGRect)oldFrame  Tv:(TileView*)tilView
{
    CGRect newframe=oldFrame;
    
    
    newframe=[self getFreeSlotFrame:tilView];
    return newframe;
}


-(void)handleTap:(UITapGestureRecognizer*)tap
{
    TileView *tView=(TileView*)tap.view;
    
    
    tView.lblT.textColor=[UIColor whiteColor];
    
    if ([tView isKindOfClass:[TileView class]])
    {
        if (tView.isSelected==NO)
        {
            
            tView.isSelected=YES;
            [arrSelectedCharachtars addObject:tView];
            
             [arrStealedCharsMainArray addObject:tView];
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
    
     return ifDefiniationExists;
}




-(IBAction)btnPauseClicked:(id)sender
{
    //    ispaused=YES;
    viewPauseGame.frame=self.view.frame;
    [self.view addSubview:viewPauseGame];
    [self.view bringSubviewToFront:viewPauseGame];
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
    
     self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [viewPauseGame removeFromSuperview];
    [self removeAllObservers];
     HomeVC *vc=[[HomeVC alloc]init];
     [App_Delegate changeRootVieController:vc];
    
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
        // view.tag=arrUserALLWords.count+100;
        //         gameOwnerScore=gameOwnerScore+scoreToIncrease;
        //         lblGameOwnerScore.text=[NSString stringWithFormat:@"Score: %d",gameOwnerScore];
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
//    return;
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:gameId forKey:@"game_id"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:Game_Quit_User Body:myString withID:strMessageID];
    
    
}


-(void)sendStackTapSubject:(NSDictionary*)dictChar
{
//    return;

    stackTappedReceived=NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:gameId forKey:@"game_id"];
    [dict setObject:[dictChar objectForKey:@"id"] forKey:@"character_id"];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:STACK_TAPPED Body:myString withID:strMessageID];
    
    
     
    
    
    
}


-(void)sendWordSubmittedPacket
{
//    return;
    
    
    if (![ObjApp_Delegate isXmppConnectedAndAuthenticated]) {
        return;
    }
    
    NSMutableArray *arrChars=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:gameId forKey:@"game_id"];
    
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
//    return;
    
    if (![ObjApp_Delegate isXmppConnectedAndAuthenticated]) {
        return;
    }
    
    NSMutableArray *arrChars=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:gameId forKey:@"game_id"];
    
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
                     // [arrCharachtersToRemove addObject:dict];
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






-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==101)
    {
        [self removeAllObservers];
        HomeVC *vc=[[HomeVC alloc]init];
        [App_Delegate changeRootVieController:vc];
    }
}



#pragma mark Steel Mode Methods

#pragma mark stealMode Case first  =>  users own word + one word from pool

// this method will disables the other word in steal mode. only the current word will be able to Steal


#pragma mark stealMode Case second => users own word + opponent one word + one char from pool



#pragma mark stealMode Case third  =>  users own word + opponent one word


-(void)tileSelectedForStealing:(UITapGestureRecognizer*)tap
{
    
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
    
    
    [Anagrams_NotificationCenter removeObserver:self name:STACK_TAPPED object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:SUBMIT_WORD object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:WORD_COMPLETED object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:SUBMIT_WORD_ERROR object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:GAME_RESULT object:nil];
    
    
    [Anagrams_NotificationCenter removeObserver:self name:GAME_TIMEOUT object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:Game_Quit_User object:nil];
    
    
    [Anagrams_NotificationCenter removeObserver:self name:GAME_TURN_CHANGE object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:START_GAME object:nil];
    [Anagrams_NotificationCenter removeObserver:self name:USER_TURNGAME_WON object:nil];

    [Anagrams_NotificationCenter removeObserver:self name:TURN_CHECKER object:nil];

    self.isOpponent=NO;
    self.dictMain=nil;
}


#pragma mark Offline Game


-(void)setALLpageDataAccordingtoCurrentConditionofGame
{
    
    NSDictionary *dictScore=[self.dictMain objectForKey:@"score"];
    
    if (dictScore) {
        
        NSString *strOppID=[self.dictMain objectForKey:@"opponent_id"];

        if (![strOppID isEqualToString:ObjApp_Delegate.currentUser.userID])
        {
            lblGameOponentScore.text=[[dictScore objectForKey:@"Opponent_score"]objectForKey:@"opponent_score"];
            lblGameOwnerScore.text=[[dictScore objectForKey:@"user_score"]objectForKey:@"user_score"];
        }
        else
        {
            lblGameOponentScore.text=[[dictScore objectForKey:@"user_score"]objectForKey:@"user_score"];
            lblGameOwnerScore.text=[[dictScore objectForKey:@"Opponent_score"]objectForKey:@"opponent_score"];

        }
    }

    
    [self arrangeTilesInPoolForOfflineMode];
    
    NSString *strGameOwner=[self.dictMain objectForKey:@"game_owner"];
    
    if ([ObjApp_Delegate.currentUser.userID isEqualToString:strGameOwner])
    {
        [self prefillTheUsersAlreadySubmittedWords];
        [self prefillTheOponentAlreadySubmittedWords];

    }
    else
    {
        [self prefillTheUsersAlreadySubmittedWords1];
        [self prefillTheOponentAlreadySubmittedWords1];

    }
    
     
}

-(void)arrangeTilesInPoolForOfflineMode
{
    NSArray *arrTilesToShowInStack=[self.dictMain objectForKey:@"stack_tapped"];
    
    for (int i=0; i<arrTilesToShowInStack.count; i++) {
        NSDictionary *dict=[arrTilesToShowInStack objectAtIndex:i];
        [self performSelector:@selector(addTilesInPoolForOpponentTapped:) withObject:dict afterDelay:0.2*i];
    }
    
}

-(void)prefillTheUsersAlreadySubmittedWords
{

    NSMutableArray *arrWords=[[self.dictMain objectForKey:@"submit_words"] objectForKey:@"user_submitted"];
    for (int i=0; i<arrWords.count; i++) {
        
        NSArray  *arrChars=[[[arrWords objectAtIndex:i]objectForKey:@"word_stack"]JSONValue];
        NSString *strWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrChars.count, labelwidthAndheight)];
        for (int j=0; j<arrChars.count; j++) {
            
            NSMutableDictionary *dict=[arrChars objectAtIndex:j];
            UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
            tapT.numberOfTapsRequired = 1;
            tapT.delegate=self;
            TileView *viewTile=[TileView initWithFrame:CGRectMake(j*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewTile.lblT.text= [dict objectForKey:@"char"];
            viewTile.userInteractionEnabled=YES;
            viewTile.dictCharData=dict;
            NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
            [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
            viewTile.dictTileFrame=dictF;
            [viewTile addGestureRecognizer:tapT];
            
            viewTile.isTilesBelongsToScrollView=YES;
            
            viewTile.isLowerScrollWord=YES;
            viewTile.isUpparScrollWord=NO;

            strWord=[strWord stringByAppendingString:[dict objectForKey:@"char"]];
            view.strWordString=strWord;
            view.wordScore=scoreToIncrease;
             [view addSubview:viewTile];
         }
        [arrUserALLWords addObject:view];
     }
 
    [self arrangeUserScrollviewAfterWordCompeltion];
}

-(void)prefillTheUsersAlreadySubmittedWords1
{
    
    NSMutableArray *arrWords=[[self.dictMain objectForKey:@"submit_words"] objectForKey:@"opponent_submitted"];
    for (int i=0; i<arrWords.count; i++) {
        
        NSArray  *arrChars=[[[arrWords objectAtIndex:i]objectForKey:@"word_stack"]JSONValue];
        NSString *strWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrChars.count, labelwidthAndheight)];
        for (int j=0; j<arrChars.count; j++) {
            
            NSMutableDictionary *dict=[arrChars objectAtIndex:j];
            UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
            tapT.numberOfTapsRequired = 1;
            tapT.delegate=self;
            TileView *viewTile=[TileView initWithFrame:CGRectMake(j*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewTile.lblT.text= [dict objectForKey:@"char"];
            viewTile.userInteractionEnabled=YES;
            viewTile.dictCharData=dict;
            NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
            [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
            viewTile.dictTileFrame=dictF;
            [viewTile addGestureRecognizer:tapT];
            
            viewTile.isTilesBelongsToScrollView=YES;
            
            viewTile.isLowerScrollWord=YES;
            viewTile.isUpparScrollWord=NO;
            
            strWord=[strWord stringByAppendingString:[dict objectForKey:@"char"]];
            view.strWordString=strWord;
            view.wordScore=scoreToIncrease;
            [view addSubview:viewTile];
        }
        [arrUserALLWords addObject:view];
    }
    
    [self arrangeUserScrollviewAfterWordCompeltion];
}






-(void)prefillTheOponentAlreadySubmittedWords
{
   
    NSMutableArray *arrWords=[[self.dictMain objectForKey:@"submit_words"] objectForKey:@"opponent_submitted"];
    for (int i=0; i<arrWords.count; i++) {
        
        NSArray  *arrChars=[[[arrWords objectAtIndex:i]objectForKey:@"word_stack"]JSONValue];
        NSString *strWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrChars.count, labelwidthAndheight)];
        for (int j=0; j<arrChars.count; j++) {
            
            NSMutableDictionary *dict=[arrChars objectAtIndex:j];
            UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
            tapT.numberOfTapsRequired = 1;
            tapT.delegate=self;
            TileView *viewTile=[TileView initWithFrame:CGRectMake(j*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewTile.lblT.text= [dict objectForKey:@"char"];
            viewTile.userInteractionEnabled=YES;
            viewTile.dictCharData=dict;
            NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
            [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
            viewTile.dictTileFrame=dictF;
            [viewTile addGestureRecognizer:tapT];
            
            viewTile.isTilesBelongsToScrollView=YES;
            
            viewTile.isLowerScrollWord=NO;
            viewTile.isUpparScrollWord=YES;
            
            strWord=[strWord stringByAppendingString:[dict objectForKey:@"char"]];
            view.strWordString=strWord;
            view.wordScore=scoreToIncrease;
            [view addSubview:viewTile];
        }
        [arrOpponentAllWord addObject:view];
    }
    
    [self arrangeOppponentScrollviewAfterWordCompeltion];

}


-(void)prefillTheOponentAlreadySubmittedWords1
{

    NSMutableArray *arrWords=[[self.dictMain objectForKey:@"submit_words"] objectForKey:@"user_submitted"];
    for (int i=0; i<arrWords.count; i++) {
        
        NSArray  *arrChars=[[[arrWords objectAtIndex:i]objectForKey:@"word_stack"]JSONValue];
        NSString *strWord=@"";
        BaseViewForTiles *view=[[BaseViewForTiles alloc]initWithFrame:CGRectMake(0, 0, labelwidthAndheight*arrChars.count, labelwidthAndheight)];
        for (int j=0; j<arrChars.count; j++) {
            
            NSMutableDictionary *dict=[arrChars objectAtIndex:j];
            UITapGestureRecognizer *tapT=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileSelectedForStealing:)];
            tapT.numberOfTapsRequired = 1;
            tapT.delegate=self;
            TileView *viewTile=[TileView initWithFrame:CGRectMake(j*labelwidthAndheight,0,labelwidthAndheight,labelwidthAndheight)];
            viewTile.lblT.text= [dict objectForKey:@"char"];
            viewTile.userInteractionEnabled=YES;
            viewTile.dictCharData=dict;
            NSMutableDictionary *dictF=[[NSMutableDictionary alloc]init];
            [dictF setObject:[NSValue valueWithCGRect:viewTile.frame] forKey:@"frame"];
            viewTile.dictTileFrame=dictF;
            [viewTile addGestureRecognizer:tapT];
            
            viewTile.isTilesBelongsToScrollView=YES;
            viewTile.isLowerScrollWord=NO;
            viewTile.isUpparScrollWord=YES;
            
            strWord=[strWord stringByAppendingString:[dict objectForKey:@"char"]];
            view.strWordString=strWord;
            view.wordScore=scoreToIncrease;
            [view addSubview:viewTile];
        }
        [arrOpponentAllWord addObject:view];
    }
    
    [self arrangeOppponentScrollviewAfterWordCompeltion];
    
}


// Game Turn Change notification will be sent from here
-(IBAction)sendGameTurnPacket
{
    
    btnTurnChangeUser.hidden=YES;
    btnTurnChangeOppont.hidden=NO;
    btnStack.userInteractionEnabled=NO;

    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    [dict setObject:gameId forKey:@"game_id"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *strMessageID=[App_Delegate getMessageID];
    [ObjApp_Delegate.xmppManager sendCustomMessageTo:kBotId withSubject:GAME_TURN_CHANGE Body:myString withID:strMessageID];

}

// Game turn change notification received here

-(void)gameTurnChangedPacketReceived
{

    btnTurnChangeUser.hidden=NO;
    btnTurnChangeOppont.hidden=YES;
    btnStack.userInteractionEnabled=YES;
    
    btnUserStatus.selected=YES;
    btnOpponentStatus.selected=NO;
    
    tilesRevealCounter=0;

}

-(void)userWonTheGame:(NSNotification*)notifi
{
   
    NSDictionary *dictInfo=(NSDictionary*)notifi.object;
    
    NSString *strWinnerName=[dictInfo objectForKey:@"winner"];
    NSString *strLooser=[dictInfo objectForKey:@"loser"];

    NSString *strWinDiff=[dictInfo objectForKey:@"difference"];

    dictWin=dictInfo;
    //loser
    if ([[dictInfo objectForKey:@"winner_id"]isEqualToString:ObjApp_Delegate.currentUser.userID]) {
        
        lblWinnerText.text=[NSString stringWithFormat:@"You beat %@ by %@ points",strLooser,strWinDiff];//@"";
        [self showGameWinningPopUp];

     }
    else
    {
        
        lblLostText.text=[NSString stringWithFormat:@"You Lost to %@ by %@ points",strWinnerName,strWinDiff];//@"";

        [self showGameLoosingPopup];

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
        [self.view addSubview:vwVictroy];
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
        [self.view addSubview:vwLost];
    }];
    
}



#pragma mark Rematch Functions and notifications

-(IBAction)btnRematchClicked:(id)sender
{
    [self sendInvitationToRematch];
}

-(void)sendInvitationToRematch
{
     NSMutableDictionary *dictRes=[[NSMutableDictionary alloc]init];
    [dictRes setObject:ObjApp_Delegate.currentUser.userID forKey:@"user_id"];
    
    NSString *strGameOwner=[self.dictMain objectForKey:@"game_owner"];
    NSString *strOppr=[self.dictMain objectForKey:@"opponent_id"];

    if (strGameOwner&&strGameOwner.length>0) {

        if ([strOppr isEqualToString:ObjApp_Delegate.currentUser.userID]) {
            
            [dictRes setObject:[NSString stringWithFormat:@"%@",strGameOwner] forKey:@"opponent_id"];

        }
        else
        {
            [dictRes setObject:[NSString stringWithFormat:@"%@",[self.dictMain objectForKey:@"opponent_id"]] forKey:@"opponent_id"];

        }
    }
    else
    {
        [dictRes setObject:[NSString stringWithFormat:@"%@",[self.dictMain objectForKey:@"opponent_id"]] forKey:@"opponent_id"];
        
    }
    [dictRes setObject:@"" forKey:@"user_name"];
    [dictRes setObject:@"offline" forKey:@"mode"];
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
        NSLog(@"Response of Game Start Subject%@",dict);
        App_Delegate.objGameOffline=(OfflineGameVC*)[App_Delegate getGameViewControllerObject:NO];
        App_Delegate.objGameOffline.dictMain=dict;
        [App_Delegate changeRootVieController:App_Delegate.objGameOffline];
}



-(void)invitationRejected
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Game Invitation Rejected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag=456;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)checkTurnIsValidOrNot:(NSNotification*)notification
{

    NSDictionary*dict =(NSDictionary*)notification.object;
    tilesRevealCounter=[[dict objectForKey:@"count"]intValue];
    NSLog(@"dict of %@",dict);

    if (tilesRevealCounter>=3)
    {
        [self sendGameTurnPacket];
    }
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
        /*
         SystemSoundID soundID;
         AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
         AudioServicesPlaySystemSound(soundID);
         AudioServicesDisposeSystemSoundID(soundID);
         */
        
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
    content.contentDescription=[NSString stringWithFormat:@"I beat %@ in anagrams.io by %@ points!",[dictWin objectForKey:@"looser"],[dictWin objectForKey:@"difference"]];
    
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
    
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    
}
@end
