//
//  AppDelegate.h
//  Anagram
//
//  Created by Ashok Choudhary on 05/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvitationPopupVC.h"
#import "OfflineGameVC.h"
#import "AcceptTurnBasedPopUpVC.h"


@class  ViewController;
@class  OfflineGameVC;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIGestureRecognizerDelegate>

@property (strong ,nonatomic)ObjUser *currentUser;
@property (strong, nonatomic) UIWindow *window;
@property BOOL isLoginWithFaceBook;
@property (strong, nonatomic)InvitationPopupVC *InviteVc;
@property (strong, nonatomic) XMPPManager *xmppManager;
@property (strong,nonatomic)NSString *currentGameId;
@property (strong,nonatomic)ViewController *objGameOnline;
@property (strong,nonatomic)OfflineGameVC  *objGameOffline;
@property (strong,nonatomic)AcceptTurnBasedPopUpVC *messageNotification;
@property (strong,nonatomic)NSString *strToken;

-(BOOL)isXmppConnectedAndAuthenticated;
-(NSString*)getMessageID;
-(void)showInviteVc;
- (void)saveCustomObject:(ObjUser *)object key:(NSString *)key;
- (ObjUser *)loadCustomObjectWithKey:(NSString *)key;
-(void)changeRootVieController:(UIViewController*)VC;
-(void)tryToConnectWithXmppInBG;
-(void)doNotificationsStuffHere;
-(UIViewController*)getGameViewControllerObject:(BOOL)isOnline;

-(void)showAlertView:(NSString*)strTitle strMessage:(NSString*)strMessage;


@end

