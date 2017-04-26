#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define appname               @"Anagrams"
#define ObjApp_Delegate      ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define AppUserDefault        [NSUserDefaults standardUserDefaults]

#define mainurl                 @"http://anagramsio.com/app/index.php/api/user/"



#define  signIn                  (mainurl  @"login")
#define  signUp                  (mainurl  @"register")
#define  signInSocial            (mainurl  @"social_login")
#define checkUser                (mainurl  @"checkuser")
#define forgotPasswordApi        (mainurl  @"forgetpassword")
#define  SaveFBFriends           (mainurl  @"SaveFBFriend")
#define  SaveFBFriends_test      (mainurl  @"SaveFBFriend_test")
#define  registerDevice          (mainurl  @"RegisterDevice")
//#define  getFBFriendsList      (mainurl  @"GetFBFriend")
#define  getFriendsList          (mainurl  @"GetFriend")
#define  WordofTheDay            (@"http://anagramsio.com/app/index.php/api/Game/WordOfDay")
#define leaderboardapi           (mainurl  @"LeaderBoard")
#define getUserDetails           (mainurl  @"GetUser")
#define updateUserDetails        (mainurl  @"ProfileUpdate")


#define  mainUrlOfflineApis      @"http://anagramsio.com/app/index.php/api/"

#define getusersGamesDetail      (mainUrlOfflineApis @"Game/GetUserGameDetail")
#define getOfflineGameDetails    (mainUrlOfflineApis @"OfflineGame/GameDetail")
#define getPendingGamesList      (mainUrlOfflineApis @"OfflineGame/GetPandingGame")


@class AppDelegate;

@interface APIsList : NSObject

+(BOOL)isInternetAvailable;
+(void)sendJasonDATa:(NSDictionary *)dicParameters url:(NSString*)strAPIURL Selector:(SEL )selector WithCallBackObject:(id)objcallbackObject;
+(void)callPostAsyncAPIUrl:(NSString *)url withParameter:(NSMutableDictionary *)params CallBackMethod:(SEL)selector toTarget:(UIViewController *)target showHUD:(BOOL)showHUD;

+(void)callPostAsyncAPIFromAppdelegate_Url:(NSString *)url withParameter:(NSMutableDictionary *)params CallBackMethod:(SEL)selector toTarget:(AppDelegate *)target showHUD:(BOOL)showHUD;

@end

