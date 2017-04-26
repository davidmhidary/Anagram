//
//  ViewController.h
//  Anagram
//
//  Created by Ashok Choudhary on 05/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lexicontext.h"
#import "BaseViewForTiles.h"
#import "CHCircleGaugeView.h"
#import <AVFoundation/AVFoundation.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "IOverlayView.h"

@interface ViewController : UIViewController<UIAlertViewDelegate,UIGestureRecognizerDelegate,FBSDKSharingDelegate,IovelayDelegates>

{
    IBOutlet UIButton *btnStack,*btnStar,*btnSubmit;
    int counter;
    
    IBOutlet UIView *viewPauseGame;
    
   // NSArray *arrXs,*arrYs;
    
    NSMutableArray *arrSelectedCharachtars;
    
    //user1 and user2 scrolls
    
    IBOutlet UIScrollView *scrlUser1,*scrlUser2;
    IBOutlet UIScrollView *scrlWordUser1,*scrlWordUser2;
    int submittClickedOwner, submitClickedOponent;
    int Xcounter;
    int Ycounter;
    int vowelCounter,consonantCounter;
    NSString *lastVowel,*lastConsonant;
    NSMutableArray *arrRandomFrames;
    
    
    //
    NSTimer *timer15Sec;
    NSTimer *timer4Minutes;
    IBOutlet  UILabel *lbl15Sec,*lbl4Mins;
    IBOutlet UIView *vwConnectionLost;
    IBOutlet UILabel *lblGameOwnerScore,*lblGameOponentScore;
    int counter15sec;
    int counter4Minutes;
    IBOutlet UIImageView *imgStatusIndicator;
    IBOutlet UIImageView *imgOnlineOrOff,*imgOnlineOrOffOpponent;
    BOOL ispaused;
    BOOL shouldShowUserOnline;
    IBOutlet UIImageView *imagSeprater1,*imagSeprater2;
    NSMutableArray *arrALlCharactersMain,*arrShuffledArray;
    NSMutableArray *arrSelectedFrames;
    NSMutableArray *arrCurrentTilesInPOOL;
    int gameOwnerScore;
    int gameOpponentScore;
    
    BOOL iswordFoundForSuggestion;
    NSString *suggestedWord;
    int scoreToIncrease;
    
    BOOL isStealModeOn,isTileSelectedFromPool;
    NSMutableArray *arrStealedCharsMainArray,*arrStealCharsTemparray;
    
    IBOutlet UIView *vwUserWordBox;
    
    NSMutableArray *arrUserALLWords;
    NSMutableArray *arrOpponentAllWord;
    
//    UIView *refUserView;
//    UIView *refOpponentView;
    
    BOOL isWordFound;
    NSMutableArray *arrWordsFound;
    int requiredWordLength,poolCharacterLength;
    NSThread *threadwordSuggest;
    Lexicontext *Lexdictionary;
    NSMutableDictionary *dictTempWordsToCheck;
    //Seperate arrays for Vowels and Consonats
    
    NSMutableArray *arrWovelsArray;
    NSMutableArray *arrConsonatsArray;
    
    
    
    //iboutlets for refrence view which are now under Stealing Mode
    
    BaseViewForTiles *refViewForSteal_User,*refViewForSteal_Opponent;
    
    
    //Helping verbs array
    
    NSMutableArray *arrHelpingVerb;
    
    BOOL stackTappedReceived;
    BOOL isConnectedToXmpp,isTryingToConnect;
    
    IBOutlet UILabel *lblGameID;
    
    AppDelegate *app;
    
    //Chcircle view
    
    IBOutlet CHCircleGaugeView *progressCircle;
    
    UIColor *red,*green,*yellow;
    
    
    IBOutlet UIButton *btnUserStatus;
    IBOutlet UIButton *btnOpponentStatus;
    
    
    // Victory View
    
    IBOutlet UIView *vwVictroy;
    IBOutlet UIView *vwLost;

    AVAudioPlayer *player;
    
    IBOutlet UILabel *lblLostText,*lblLostHeader;
    IBOutlet UILabel *lblWinnerText,*lblPuaseTime;

    
    IBOutlet UIImageView *imgHand;
    
    
    IOverlayView *overly;
    BOOL isOverlyRemoved;
    
}
@property (nonatomic,strong) NSDictionary *dictMain;
@property BOOL isOpponent;
-(void)removeAllObservers;
@end

