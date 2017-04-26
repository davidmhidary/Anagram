//
//  XMPPManager.h
//  NukeMessenger
//
//  Created by Ram on 18/11/14.
//  Copyright (c) 2014 Ramprakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPStream.h"
#import "XMPPPing.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPIQ.h"
#import "XMPPIQ+XEP_0055.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPProcessOne.h"
#import "XMPPMessageDeliveryReceipts.h"



#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPIncomingFileTransfer.h"
#import "XMPPOutgoingFileTransfer.h"
#import "XMPPLastActivity.h"
//For Make sound beep and vibrate
#import <AudioToolbox/AudioServices.h>

@class AppDelegate;
@class MessageNotificationScreen;
@interface XMPPManager : NSObject<XMPPRosterDelegate,NSFetchedResultsControllerDelegate,XMPPIncomingFileTransferDelegate,XMPPOutgoingFileTransferDelegate,XMPPStreamDelegate> //XMPPStreamDelegate for prevent receipt,mani
{
    
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPMUC *xmppMUC;
    XMPPRoom *xmppRoom;
    XMPPPing *xmppPing;
    XMPPLastActivity *xmppLastActivity;

    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPRoomCoreDataStorage *xmppRoomDataStorage;
    
    XMPPMessageArchiving *xmppMessageArchiving;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
    
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPProcessOne *xmppProcessOne;
    XMPPMessageDeliveryReceipts *xmppMessageDeliveryReceipts;
    
    XMPPJID *myJID;
    XMPPIncomingFileTransfer *xmppIncomingFileTransfer;
    XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;
    
    NSString *password;
    BOOL isXmppConnected;
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
    
    BOOL isAnoymous;
    
    NSManagedObjectContext *managedObjectContext_roster;
    NSManagedObjectContext *managedObjectContext_messages;
	NSManagedObjectContext *managedObjectContext_capabilities;
    
    NSFetchedResultsController *rosterFetchedResultsController;
    NSFetchedResultsController *messagesFetchedResultsController;
    //    NSMutableDictionary *buddyListDic;
    //    NSMutableDictionary *chatroomListDic;
    
    NSArray *selectedBuddy;
    
}
//@property (nonatomic, strong) DBWrapper *dbObj;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, readonly) XMPPRoomCoreDataStorage *xmppRoomDataStorage;
@property (nonatomic, strong) XMPPJID *myJID;
@property (nonatomic, strong) MessageNotificationScreen *messageNotification;
@property (nonatomic, strong) NSMutableDictionary *dictStatus;
@property (nonatomic, strong) XMPPJID *myParrotID;

-(void)reachabilityChanged:(NSNotification*)note;

- (id)init;
+ (XMPPManager *)sharedManager;
- (void)setupStream;
-(void)connectToServer;
- (BOOL)connectWithJID:(NSString *)JID password:(NSString *)myPassword;
- (BOOL)anoymousConnection;
- (void)disconnect;

- (void)sendMessageTo:(XMPPJID *)targetBareID withMessage:(NSString *)newMessage;

- (NSFetchedResultsController *)messagesFetchedResultsController:(NSString *)bareJidStr addDelegate:(id)delegate;
- (NSFetchedResultsController *)rosterFetchedResultsController;

//- (void)sendSearchRequest:(NSString *)searchField;
- (NSManagedObjectContext *)managedObjectContext_roster;

-(NSString*)getMessageID;

-(XMPPJID*)getJIDfromUsername:(NSString*)strUserName;

// ** XMPP Message
-(void)sendCustomMessageTo:(NSString *)to withSubject:(NSString *)subject Body:(NSString *)body withID:(NSString *)messageID;
-(void)sendCustomMessageWithoutReceipt:(NSString *)to withSubject:(NSString *)subject Body:(NSString *)body withID:(NSString *)messageID;
-(void)sendMessage:(XMPPJID *)to Body:(NSString *)body withID:(NSString *)messageID;

//-(void)sendUpdateProfileMessage:(XMPPJID *)to withID:(NSString *)messageID;

-(void)sendFileTransferMessage:(NSString *)to withSubject:(NSString *)filename Body:(NSData *)data;

 @end
