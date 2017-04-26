//
//  XMPPManager.m
//  NukeMessenger
//
//  Created by Ram on 18/11/14.
//  Copyright (c) 2014 Ramprakash. All rights reserved.
//

#import "XMPPManager.h"
//#import "MessageNotificationScreen.h"
#import "UIImageView+WebCache.h"
//#import "DBWrapper.h"
#import "NSXMLElement+XEP_0203.h"
#import "Reachability.h"
#import "XMPPStream.h"
#import "UNIRest.h"
#import "JSON.h"
//#import "NetworkUtills.h"
//#import "GroupObject.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

static XMPPManager *sharedManager = nil;

@implementation XMPPManager

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppRoomDataStorage;
@synthesize myJID;

#pragma mark -
#pragma mark singleton
- (id)init
{
    self=[super init];
    if(self){
//        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [self setupStream];
        [Anagrams_NotificationCenter addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
//        self.dbObj=[[DBWrapper alloc] initWith];
        
        //        [Anagrams_NotificationCenteraddObserver:self
        //                                                selector:@selector(sendXMPPMessage:)
        //                                                    name:kSendMessages object:nil];
        //        [Anagrams_NotificationCenteraddObserver:self
        //                                                selector:@selector(sendGroupChat:)
        //                                                    name:kSendGroupChat object:nil];
        Reachability * reach = [Reachability reachabilityWithHostName:@"www.google.com"];
        //
        //        reach.reachableBlock = ^(Reachability * reachability)
        //        {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //            //    NSLog(  @"Block Says Reachable");
        //            });
        //        };
        //
        //        reach.unreachableBlock = ^(Reachability * reachability)
        //        {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //           //    NSLog( @"Block Says Unreachable");
        //            });
        //        };
        
        [reach startNotifier];
        
    }
    return self;
}
+ (XMPPManager *)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark -
#pragma mark Manage Private
- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    xmppStream = [[XMPPStream alloc]init];
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    //    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithDatabaseFilename:@"XMPPRoster.sqlite"];
    
//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppRoomDataStorage = [[XMPPRoomCoreDataStorage alloc] initWithInMemoryStore];
    xmppMUC = [[XMPPMUC alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
//    xmppMessageArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] initWithDatabaseFilename:@"XMPPMessageArchiving.sqlite"];
    
//    xmppMessageArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    xmppMessageArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] initWithInMemoryStore];
    //    dispatch_queue_t messageArchivingQueue = dispatch_queue_create("com.hktv.message.archiving", NULL);
    
    xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingStorage dispatchQueue:dispatch_get_main_queue()];
    xmppMessageArchiving.clientSideMessageArchivingOnly = YES;
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    xmppPing = [[XMPPPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppPing.respondsToQueries = YES;
    
    xmppMessageDeliveryReceipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    
    xmppProcessOne=[xmppProcessOne initWithDispatchQueue:dispatch_get_main_queue()];
    
    xmppMessageDeliveryReceipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryReceipts.autoSendMessageDeliveryRequests = YES;
    
    xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] init];
    xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_main_queue()];

    // create last activity instance, For Last seen
    //sohan
    xmppLastActivity = [[XMPPLastActivity alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    
    [xmppLastActivity addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Activate xmpp modules
    // add last scene module
    //sohan
    [xmppLastActivity activate:xmppStream];
    
    [xmppMUC               activate:xmppStream];
    [xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    [xmppPing              activate:xmppStream];
    [xmppMessageArchiving  activate:xmppStream];
    [xmppMessageDeliveryReceipts activate:xmppStream];
    [xmppIncomingFileTransfer activate:xmppStream];
    [xmppOutgoingFileTransfer activate:xmppStream];
   
    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
  
    allowSelfSignedCertificates = YES;
    allowSSLHostNameMismatch = YES;
    
}

- (void)teardownStream
{
	[xmppStream disconnect];
    
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
    [xmppIncomingFileTransfer removeDelegate:self];
 	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
    [xmppIncomingFileTransfer deactivate];
    
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
    xmppIncomingFileTransfer = nil;
}

- (void)goOnline
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[XMPPElement elementWithName:@"priority" stringValue:@"1"]];
    [presence addChild:[XMPPElement elementWithName:@"device" stringValue:@"mobile"]];
    [presence addChild:[XMPPElement elementWithName:@"status" stringValue:@"Online"]];
    
    [xmppStream sendElement:presence];
    //    if(![kXMPPServerHost isEqualToString:@"chat.facebook.com"]){
    //        [self sendXMPPChatRoomQuery];
    //    }
    [Anagrams_NotificationCenter postNotificationName:kServerLoginSuccess object:self];
//    [self requestSearchFields];
     self.myParrotID=[self getJIDfromUsername:kNukeMyXMPPBot];
//    [self getAllRegisteredUsers];
    
    NSLog(@"*********************Now you are online**********************");
}

- (void)goOffline
{
    NSLog(@"*********************Now XMPP Disconnected**********************");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}


- (void)failedToConnect
{
    [Anagrams_NotificationCenter postNotificationName:kServerLoginFail object:self];
    [xmppStream disconnect];
}


- (void)pushLocalNotification:(XMPPMessage *)message
{
//    NSString *displayName =[[message from]user];
//    NSString *body = [[message elementForName:@"body"] stringValue];
//    NSString *messagetype = [[message elementForName:@"subject"] stringValue];
//
//    NSError * error = nil;
//    id json = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//    if ([json isKindOfClass:[NSDictionary class]])
//    {
//        NSDictionary *dicResponse=json;
//    }
}

- (void)pushLocalNotificationForGroup:(XMPPMessage *)message
{
    
}

#pragma mark -
#pragma mark XMPPStream Connect/Disconnect

-(void)connectToServer
{
    NSLog(@"*********************Now trying to connect **********************");
    
//    NSString *completeJID = [[Anagrams_Defaults objectForKey:kXMPPmyJID] stringByAppendingFormat:@"@%@",kXMPPServerDomain];
    
    NSString *completeJID = [Anagrams_Defaults objectForKey:kXMPPmyJID];
    if(![self connectWithJID:completeJID password:[Anagrams_Defaults objectForKey:kXMPPmyPassword]])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Server not connected." delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}


- (BOOL)connectWithJID:(NSString *)JID password:(NSString *)myPassword
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
     if(JID == nil || myPassword == nil)
        return NO;
    // NSString *resource = [NSString stringWithFormat:@"%@",kXMPPResource];
//    NSString *resource = [NSString stringWithFormat:@"Nuke%@",[self getMessageID]];
//    myJID = [XMPPJID jidWithString:JID resource:resource];
   
    NSString *resource = [NSString stringWithFormat:@"%@",kXMPPResource];
//    NSString *resource = [NSString stringWithFormat:@"Nuke%@",[self getMessageID]];
    myJID = [XMPPJID jidWithString:JID resource:resource];
    [xmppStream setMyJID:myJID];
    [xmppStream setHostName:kXMPPServerHost];
    [xmppStream setHostPort:5222];
    password = myPassword;
    NSError *error;
    isAnoymous = NO;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    return YES;
}

- (BOOL)anoymousConnection
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    NSString *resource = [NSString stringWithFormat:@"%@",kXMPPResource];
    myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"anoymous@%@",kXMPPServerDomain] resource:resource];
    [xmppStream setMyJID:myJID];
    [xmppStream setHostName:kXMPPServerHost];
    [xmppStream setHostPort:5222];
    NSError *error;
    isAnoymous = YES;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    // [self teardownStream];
}
#pragma mark -
#pragma mark XMPPStream Delegate
- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:kXMPPServerDomain])
		{
			if ([virtualDomain isEqualToString:kXMPPServerDomain])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSError *secureError = nil;
    NSError *authenticationError = nil;
    BOOL isSecureAble = (![sender isSecure])&& [sender supportsStartTLS];
	if (isSecureAble) {
        [sender secureConnection:&secureError];
    }
    if (isAnoymous) {
        if (![[self xmppStream] authenticateAnonymously:&authenticationError])
        {
            if (![[self xmppStream] supportsAnonymousAuthentication]) {
                return;
            }
            DDLogError(@"Can't anoymous: %@", authenticationError);
            isXmppConnected = NO;
            return;
        }
    }else{
        if (![[self xmppStream] authenticateWithPassword:password error:&authenticationError])
        {
            DDLogError(@"Error authenticating: %@", authenticationError);
            isXmppConnected = NO;
            return;
        }
    }
    isXmppConnected = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
////    NSLog(@"begin");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //    [xmppRoster fetchRoster];
    
    //  [self resetRosterStatus];
//    [App_Delegate performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:YES];
    [self goOnline];
    [self sendAllUnsentMessages];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate %@",[error description]);
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self failedToConnect];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
////    NSLog(@"didReceiveIQ:%@",iq);
//    NSXMLElement *queryElement = [iq elementForName: @"command" xmlns: @"http://jabber.org/protocol/commands"];
//    
//    if (queryElement) {
//        
//    }
    return NO;
}
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
//{
//    //	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq type]);
//    //    if ([[iq elementID] isEqualToString:kIQChatroomID]) {
//    ////        [self receiveChatroomQueryResult:iq];
//    //    }else if([iq isSearchResult]){
//    //        NSDictionary *userInfo = [iq searchResults];
//    //        [Anagrams_NotificationCenter postNotificationName:kSearchResultNotification object:self userInfo:userInfo];
//    //    }
//	return NO;
//}

//Showing Online offline
 - (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [Anagrams_NotificationCenter
     postNotificationName:kServerDisconnect object:self];
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect];
	}
    else {
        //Lost connection
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////******CURRENTLY NOT USEING*******////
- (NSManagedObjectContext *)managedObjectContext_roster
{
    //	NSAssert([NSThread isMainThread],
    //	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
    return [xmppRosterStorage mainThreadManagedObjectContext];
	if (managedObjectContext_roster == nil)
	{
		managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[Anagrams_NotificationCenter addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
    
	
	return managedObjectContext_roster;
}

- (NSManagedObjectContext *)managedObjectContext_messages
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_messages == nil)
	{
		managedObjectContext_messages = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppMessageArchivingStorage persistentStoreCoordinator];
		[managedObjectContext_messages setPersistentStoreCoordinator:psc];
		[Anagrams_NotificationCenter addObserver:self
		                                         selector:@selector(messagesContextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_messages;
}

- (NSManagedObjectContext *)managedObjectContext_chatroom
{
    NSAssert([NSThread isMainThread],
             @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
    return nil;
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_capabilities == nil)
	{
		managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[Anagrams_NotificationCenter addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_capabilities;
}

- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
            
            
		});
    }
	
    
	if (sender != managedObjectContext_capabilities &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_capabilities", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
		});
	}
}
- (void)messagesContextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
    if(sender != managedObjectContext_messages &&
       [sender persistentStoreCoordinator] == [managedObjectContext_messages persistentStoreCoordinator])
    {
 		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_message", THIS_FILE, THIS_METHOD);
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_messages mergeChangesFromContextDidSaveNotification:notification];
            
		});
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSuserFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)rosterFetchedResultsController
{
	if (rosterFetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"streamBareJidStr == %@", [[xmppStream myJID] bare]];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
		rosterFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                             managedObjectContext:moc
                                                                               sectionNameKeyPath:@"sectionNum"
                                                                                        cacheName:nil];
		[rosterFetchedResultsController setDelegate:self];
		NSError *error = nil;
		if (![rosterFetchedResultsController performFetch:&error])
		{
//			NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return rosterFetchedResultsController;
}

////******CURRENTLY NOT USEING*******//// &

//- (NSFetchedResultsController *)fetchedResultsController
//{
//	if (rosterFetchedResultsController == nil)
//	{
//		NSManagedObjectContext *moc = [self managedObjectContext_roster];
//
//		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
//		                                          inManagedObjectContext:moc];
//
//		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
//		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
//
//		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
//
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		[fetchRequest setEntity:entity];
//		[fetchRequest setSortDescriptors:sortDescriptors];
//		[fetchRequest setFetchBatchSize:10];
//
//		rosterFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//		                                                               managedObjectContext:moc
//		                                                                 sectionNameKeyPath:@"sectionNum"
//		                                                                          cacheName:nil];
//		[rosterFetchedResultsController setDelegate:self];
//
//
//		NSError *error = nil;
//		if (![rosterFetchedResultsController performFetch:&error])
//		{
//        //    NSLog(@"fetchedResultsController performFetch:%@",error);
//			//DDLogError(@"Error performing fetch: %@", error);
//		}
//
//	}
//
//	return rosterFetchedResultsController;
//}
//


- (NSFetchedResultsController *)messagesFetchedResultsController:(NSString *)bareJidStr addDelegate:(id)delegate
{
	if (messagesFetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_messages];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",[myJID bare], bareJidStr];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:20];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
		messagesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                               managedObjectContext:moc
                                                                                 sectionNameKeyPath:@"sectionNum"
                                                                                          cacheName:nil];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",[myJID bare], bareJidStr];
        [messagesFetchedResultsController.fetchRequest setPredicate:predicate];
    }
    [messagesFetchedResultsController setDelegate:delegate];
    
    NSError *error = nil;
    if (![messagesFetchedResultsController performFetch:&error])
    {
//    //    NSLog(@"Error performing fetch: %@", error);
    }
    
	return messagesFetchedResultsController;
}


#pragma mark --
#pragma mark -- All Unsent Messages Send
#pragma mark --

-(void)sendAllUnsentMessages
{
//    [self.dbObj getAllUnsentMessagesList];
//    for (int i=0; i<App_Delegate.aryUnsentMessages.count; i++)
//    {
//        MessageObject *message=[App_Delegate.aryUnsentMessages objectAtIndex:i];
//        
//        NSString *strMessageID=[NSString stringWithFormat:@"%f",message.ID];
//        if (strMessageID.length<17)
//            strMessageID=[NSString stringWithFormat:@"0%@",strMessageID];
//        
//        if ([message.strType isEqualToString:kTYPE_TEXT])
//        {
//            [self sendMessage:[self getJIDfromUsername:message.strFriendUserName] Body:message.strBody withID:strMessageID];
//        }
//        //        else if ([message.strType isEqualToString:kTYPE_IMAGE])
//        //        {
//        //            [self sendImage:[self getJIDfromUsername:message.strFriendUserName] :message.strBody withID:strMessageID];
//        //        }
//        //        else if ([message.strType isEqualToString:kTYPE_VIDEO])
//        //        {
//        //            [self sendVideo:[self getJIDfromUsername:message.strFriendUserName] :message.strBody withID:strMessageID];
//        //        }
//        //        else if ([message.strType isEqualToString:kTYPE_AUDIO])
//        //        {
//        //            [self sendAudio:[self getJIDfromUsername:message.strFriendUserName] :message.strBody withID:strMessageID];
//        //        }
//    }
}



#pragma mark --
#pragma mark -- Sending Text Message
#pragma mark --


- (void)sendMessageTo:(XMPPJID *)targetBareID withMessage:(NSString *)newMessage;
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:newMessage];
    
    XMPPMessage *message = [XMPPMessage elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[targetBareID full]];
    [message addAttributeWithName:@"from" stringValue:[myJID full]];
    int timeStamp = (int)[[NSDate date] timeIntervalSince1970];
    NSString * messageID = [NSString stringWithFormat:@"%@%d%@",[myJID user],timeStamp,[targetBareID user]];
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
    [receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild:receiptRequest];
    [message addChild:body];
    XMPPElementReceipt *receipt = nil;
    [xmppStream sendElement:message andGetReceipt:&receipt];
    if ([receipt wait:-1]) {
        
    };
}

//-(void)sendMessage:(XMPPJID *)to :(NSString *)body withID:(NSString *)messageID
//{
//    int timeStamp = (int)[[NSDate date] timeIntervalSince1970];
//    NSString * messageID1 = [NSString stringWithFormat:@"%@%d%@",[myJID user],timeStamp,[to user]];
//
//    XMPPMessage *message1 = [[XMPPMessage alloc] initWithType:@"chat" to:to elementID:messageID1];
//////    NSLog(@"*****SEND TO: %@",to);
//    //  [message1 generateReceiptResponse];
//
//    NSXMLElement *mainElement = [NSXMLElement elementWithName:@"subject" stringValue:@"CHAT"];
//    NSXMLElement *element = [NSXMLElement elementWithName:@"body" stringValue:body];
//    NSXMLElement *element1 = [NSXMLElement elementWithName:@"message" stringValue:@"text"];
//    //  NSXMLElement *elementID = [NSXMLElement elementWithName:@"id" stringValue:[message1 elementID]];
//
//   // [message1 addAttributeWithName:@"id" stringValue:messageID];
//    [message1 addChild:mainElement];
//    [message1 addChild:element];
//    [message1 addChild:element1];
//    // [message1 addChild:elementID];
//    [message1 addReceiptRequest];
//
//    XMPPElementReceipt *receipt = [xmppProcessOne goOnStandby];
//    [xmppStream sendElement:message1 andGetReceipt:&receipt];
//    //NSLog(@"******SEND MESSAGE: %@",message1);
//}


#pragma mark --
#pragma mark -- Sending XMPP Custom Message
#pragma mark --

-(void)sendCustomMessageTo:(NSString *)to withSubject:(NSString *)subject Body:(NSString *)body  withID:(NSString *)messageID
{
    
    
    if (![App_Delegate isXmppConnectedAndAuthenticated]) {
        
        return;
    }
    
    XMPPMessage *message1 = [[XMPPMessage alloc] initWithType:@"chat" to:[self getJIDfromUsername:to] elementID:messageID];
   
    NSXMLElement *mainElement = [NSXMLElement elementWithName:@"subject" stringValue:subject];
    NSXMLElement *element = [NSXMLElement elementWithName:@"body" stringValue:body];
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"message" stringValue:@"text"];
    
    [message1 addChild:mainElement];
    [message1 addChild:element];
    [message1 addChild:element1];
    [message1 addReceiptRequest];
    XMPPElementReceipt *receipt = [xmppProcessOne goOnStandby];
    [xmppStream sendElement:message1 andGetReceipt:&receipt];
}

#pragma mark --
#pragma mark -- Sending XMPP Custom Message (Without Receipt)
#pragma mark --

-(void)sendCustomMessageWithoutReceipt:(NSString *)to withSubject:(NSString *)subject Body:(NSString *)body withID:(NSString *)messageID
{
    XMPPMessage *message1 = [[XMPPMessage alloc] initWithType:@"chat" to:[self getJIDfromUsername:to] elementID:messageID];

    NSXMLElement *mainElement = [NSXMLElement elementWithName:@"subject" stringValue:subject];
    NSXMLElement *element = [NSXMLElement elementWithName:@"body" stringValue:body];
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"message" stringValue:@"text"];
    //  NSXMLElement *elementID = [NSXMLElement elementWithName:@"id" stringValue:[message1 elementID]];
    
    [message1 addChild:mainElement];
    [message1 addChild:element];
    [message1 addChild:element1];
    [xmppStream sendElement:message1];
}


#pragma mark --
#pragma mark -- Sending XMPP File Transfer
#pragma mark --

-(void)sendFileTransferMessage:(NSString *)to withSubject:(NSString *)filename Body:(NSData *)data
{
    NSString *recipient = to;

    recipient=[recipient stringByAppendingFormat:@"@"];
    recipient=[recipient stringByAppendingFormat:kXMPPServerHost];
    NSString *resource = [NSString stringWithFormat:@"/%@",kXMPPResource];
    
    NSError *err;
    if (![xmppOutgoingFileTransfer sendData:data
                           named:filename
                                toRecipient:[XMPPJID jidWithString:recipient resource:resource]
                     description:@"Baal's Soulstone, obviously."
                           error:&err]) {
        DDLogInfo(@"You messed something up: %@", err);
    }
}


#pragma mark --
#pragma mark -- Sending Text Message
#pragma mark --

-(void)sendMessage:(XMPPJID *)to Body:(NSString *)body withID:(NSString *)messageID
{
    XMPPMessage *message1 = [[XMPPMessage alloc] initWithType:@"chat" to:to elementID:messageID];
    NSXMLElement *mainElement = [NSXMLElement elementWithName:@"subject" stringValue:kTYPE_TEXT];
    NSXMLElement *element = [NSXMLElement elementWithName:@"body" stringValue:body];
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"message" stringValue:@"text"];
    //  NSXMLElement *elementID = [NSXMLElement elementWithName:@"id" stringValue:[message1 elementID]];
    
    [message1 addChild:mainElement];
    [message1 addChild:element];
    [message1 addChild:element1];
    // [message1 addChild:elementID];
    [message1 addReceiptRequest];
    XMPPElementReceipt *receipt = [xmppProcessOne goOnStandby];
    [xmppStream sendElement:message1 andGetReceipt:&receipt];
    //NSLog(@"******SEND MESSAGE: %@",message1);
}



#pragma mark --
#pragma mark -- Message Sent
#pragma mark --

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"Sending Message************%@",message);
    
//    NSString *body = [[message elementForName:@"body"] stringValue];
//    NSString *messagetype = [[message elementForName:@"subject"] stringValue];
//    
//     
//    NSString *displayName = [message toStr];
//    
//    NSArray* arr = [displayName componentsSeparatedByString: @"@"];
//    displayName = [arr objectAtIndex: [arr count]-2];
//    
//    ////    NSLog(@"DISPLY*********** %@",displayName);
//    
//    NSString *strMsgID=[message messageID];
    
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error;
{
    
}

#pragma mark --
#pragma mark -- Message Received
#pragma mark --

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *messagetype = [[message elementForName:@"subject"] stringValue];
    NSLog(@"Message Received in did receive :%@ ,:-----************%@",messagetype,message);
    
    NSString *jsonBody = [[message elementForName:@"body"] stringValue];
    NSMutableDictionary *dicRes=[jsonBody JSONValue];
    
  AppDelegate * appObj=(AppDelegate*)[[UIApplication sharedApplication]delegate];

    if ([message wasDelayed])
    {
        [dicRes setObject:@"YES" forKey:@"wasDelayed"];
    }
    else
    {
        [dicRes setObject:@"NO" forKey:@"wasDelayed"];
    }
//    UINavigationController *t=(UINavigationController*)ObjApp_Delegate.window.rootViewController;

    
    if ([messagetype isEqualToString:INVITE_USER])
    {
        // this message will be received to opponent only
        [App_Delegate showInviteVc];
        [Anagrams_NotificationCenter postNotificationName:INVITE_USER object:dicRes];
    }
    else if ([messagetype isEqualToString:INVITE_SEND_NOTIFICATION])
    {
        [Anagrams_NotificationCenter postNotificationName:INVITE_SEND_NOTIFICATION object:dicRes];

    }
    else if ([messagetype isEqualToString:INVITATION_ACCEPTED])
    {
        // this message will be received to game initiater that user which was invited has accepted the request

        [Anagrams_NotificationCenter postNotificationName:INVITATION_ACCEPTED object:dicRes];
    }
    else if ([messagetype isEqualToString:INVITATION_REJECTED])
    {
        // this message will be received to game initiater that user which was invited has rejected the request

        [Anagrams_NotificationCenter postNotificationName:INVITATION_REJECTED object:dicRes];
    }
    else if ([messagetype isEqualToString:START_GAME])
    {
        // this message will be received to both game owner and opponent, here set of charachters also received to both

        [Anagrams_NotificationCenter postNotificationName:START_GAME object:dicRes];
    }
    else if ([messagetype isEqualToString:STACK_TAPPED])
    {
        
        
        NSString *strPacketGameId= [NSString stringWithFormat:@"%@",[[dicRes objectForKey:@"stack_tap"] objectForKey:@"game_id"]];
        // whenever a tile is revealed then this message is received regarding to opponent

        NSLog(@"CurrentGame Id is%@ and Packet Game ID%@",appObj.currentGameId,strPacketGameId);
        if ([appObj.currentGameId isEqualToString:strPacketGameId]) {
            [Anagrams_NotificationCenter postNotificationName:STACK_TAPPED object:dicRes];
         }
    }
    else if ([messagetype isEqualToString:SUBMIT_WORD])
    {
        // whenever an answer is submmitted then this message is received regarding to opponent
        [Anagrams_NotificationCenter postNotificationName:SUBMIT_WORD object:dicRes];
    }
    else if ([messagetype isEqualToString:WORD_COMPLETED])
    {
        NSString *strPacketGameId= [NSString stringWithFormat:@"%@",[dicRes objectForKey:@"game_id"]];

        NSLog(@"CurrentGame Id is%@ and Packet Game ID%@",appObj.currentGameId,strPacketGameId);

        if ([appObj.currentGameId isEqualToString:strPacketGameId])
        {
            [Anagrams_NotificationCenter postNotificationName:WORD_COMPLETED object:dicRes];

        }
        // whenever an answer is verified by server then this message will be received
        
    }
    else if ([messagetype isEqualToString:SUBMIT_WORD_ERROR])
    {
        [Anagrams_NotificationCenter postNotificationName:SUBMIT_WORD_ERROR object:dicRes];
    }
    else if ([messagetype isEqualToString:GAME_RESULT])
    {
        [Anagrams_NotificationCenter postNotificationName:GAME_RESULT object:dicRes];
    }
    else if ([messagetype isEqualToString:PLAYER_WON])
    {
        [Anagrams_NotificationCenter postNotificationName:PLAYER_WON object:dicRes];
    }
    else if ([messagetype isEqualToString:GAME_TIMEOUT])
    {
        [Anagrams_NotificationCenter postNotificationName:GAME_TIMEOUT object:dicRes];
    }
    else if ([messagetype isEqualToString:Game_Quit_User])
    {
        [Anagrams_NotificationCenter postNotificationName:Game_Quit_User object:dicRes];
    }
    else if ([messagetype isEqualToString:GAME_TURN_CHANGE])
    {
        [Anagrams_NotificationCenter postNotificationName:GAME_TURN_CHANGE object:dicRes];
    }
    else if ([messagetype isEqualToString:USER_TURNGAME_WON])
    {
        [Anagrams_NotificationCenter postNotificationName:USER_TURNGAME_WON object:dicRes];
    }
    else if ([messagetype isEqualToString:TURN_CHECKER])
    {
        [Anagrams_NotificationCenter postNotificationName:TURN_CHECKER object:dicRes];
    }


    
}





////////
#pragma mark --
#pragma mark -- Get XMPP JID From Username
#pragma mark --

-(XMPPJID*)getJIDfromUsername:(NSString*)strUser
{
    strUser=[strUser stringByAppendingFormat:@"@"];
    strUser=[strUser stringByAppendingFormat:kXMPPServerHost];
    XMPPJID *toJID = [XMPPJID jidWithString:strUser];
    return toJID;
}

#pragma mark --
#pragma mark -- Get MessageID
#pragma mark --

-(NSString*)getMessageID
{
   NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
   [formatter setDateFormat:@"ddMMyyyyHHmmssSSS"];
    NSString *strTimeStamp=[formatter stringFromDate:[NSDate date]];
     NSString *messageID=[NSString stringWithFormat:@"%.0f",[strTimeStamp doubleValue]];
    if (messageID.length<17)
        messageID=[NSString stringWithFormat:@"0%@",messageID];
        return messageID;
}

#pragma mark --
#pragma mark -- Get Friend Name
#pragma mark --



#pragma mark --
#pragma mark -- Internet Notification
#pragma mark --

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    if (remoteHostStatus !=NotReachable)
//    {
//    }
//
//    if([reach isReachable])
    {
//    //    NSLog( @"Notification Says Reachable");
        if ([self.xmppStream isDisconnected])
        {
            NSString *completeJID = [[Anagrams_Defaults objectForKey:kXMPPmyJID] stringByAppendingFormat:@"@%@",kXMPPServerDomain];
            [self connectWithJID:completeJID password:[Anagrams_Defaults objectForKey:kXMPPmyPassword]];
        }
        else
        {
            [self sendAllUnsentMessages];
        }
    }
    else
    {
//    //    NSLog(  @"Notification Says Unreachable");
        //        [self goOffline];
        [self.xmppStream disconnect];
    }
    
}
#pragma mark - XMPPIncomingFileTransferDelegate Methods

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    DDLogVerbose(@"%@: Incoming file transfer failed with error: %@", THIS_FILE, error);
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
               didReceiveSIOffer:(XMPPIQ *)offer
{
    DDLogVerbose(@"%@: Incoming file transfer did receive SI offer. Accepting...", THIS_FILE);
    [sender acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
              didSucceedWithData:(NSData *)data
                           named:(NSString *)name
{
    DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
    [data writeToFile:fullPath options:0 error:nil];
    
    DDLogVerbose(@"%@: Data was written to the path: %@", THIS_FILE, fullPath);
}

#pragma mark - XMPPOutgoingFileTransferDelegate Methods

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    DDLogInfo(@"Outgoing file transfer failed with error: %@", error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"There was an error sending your file. See the logs."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
    DDLogVerbose(@"File transfer successful.");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:@"Your file was sent successfully."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
