//
//  OfflineGameVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 17/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Lexicontext.h"
#import "BaseViewForTiles.h"
#import "CHCircleGaugeView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface OfflineGameVC : UIViewController<UIAlertViewDelegate,UIGestureRecognizerDelegate,FBSDKSharingDelegate>

{
    IBOutlet UIView *viewPauseGame;
    IBOutlet UIView *vwConnectionLost;
    IBOutlet UIView *vwUserWordBox;

    IBOutlet UIScrollView *scrlUser1,*scrlUser2;
    IBOutlet UIImageView *imagSeprater1,*imagSeprater2;
    IBOutlet UIButton *btnStack,*btnStar,*btnSubmit;
    IBOutlet UILabel *lblGameOwnerScore,*lblGameOponentScore;

    int submittClickedOwner, submitClickedOponent;
    int Xcounter;
    int Ycounter;
    int counter;
    int counter15sec;
    int counter4Minutes;
    int vowelCounter,consonantCounter;
    int gameOwnerScore;
    int gameOpponentScore;
    int scoreToIncrease;
    int requiredWordLength,poolCharacterLength;

    NSString *lastVowel,*lastConsonant;
    NSString *suggestedWord;
    
    NSMutableArray *arrRandomFrames;
    NSMutableArray *arrALlCharactersMain,*arrShuffledArray;
    NSMutableArray *arrSelectedFrames;
    NSMutableArray *arrCurrentTilesInPOOL;
    NSMutableArray *arrStealedCharsMainArray,*arrStealCharsTemparray;
    NSMutableArray *arrUserALLWords;
    NSMutableArray *arrOpponentAllWord;
    NSMutableArray *arrWordsFound;
    //Seperate arrays for Vowels and Consonats
    NSMutableArray *arrWovelsArray;
    NSMutableArray *arrConsonatsArray;
    NSMutableDictionary *dictTempWordsToCheck;
    //Helping verbs array
    NSMutableArray *arrHelpingVerb;
    NSMutableArray *arrSelectedCharachtars;

    BOOL ispaused;
    BOOL shouldShowUserOnline;
    BOOL iswordFoundForSuggestion;
    BOOL isStealModeOn,isTileSelectedFromPool;
    BOOL isWordFound;
    BOOL stackTappedReceived;
    BOOL isConnectedToXmpp,isTryingToConnect;

    NSThread *threadwordSuggest;
    Lexicontext *Lexdictionary;

    //iboutlets for refrence view which are now under Stealing Mode
    BaseViewForTiles *refViewForSteal_User,*refViewForSteal_Opponent;
    AppDelegate *app;
    
    NSString *gameId;
    
    IBOutlet UIButton *btnTurnChangeUser;
    IBOutlet UIButton *btnTurnChangeOppont;
    IBOutlet UIButton *btnUserStatus;
    IBOutlet UIButton *btnOpponentStatus;

    //counter to check that when 3 tiles are selected then turn should be changed
    
    int tilesRevealCounter;
    
    IBOutlet UIView *vwVictroy;
    IBOutlet UIView *vwLost;
    
    IBOutlet UILabel *lblLostText;
    IBOutlet UILabel *lblWinnerText;
    
    AVAudioPlayer *player;
    
    NSDictionary *dictWin;
}

@property (nonatomic,strong) NSDictionary *dictMain;

@property (nonatomic,strong) NSString *strCurrentUserTurnID;

@property BOOL isOpponent;
-(void)removeAllObservers;

@end


