//
//  APIsList.m
//  AnswerIt
//
//  Created by Ram on 30/10/14.
//  Copyright (c) 2014 Ramprakash. All rights reserved.
//
#import "APIsList.h"
#import "UNIRest.h"
#import "JSON.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
@implementation APIsList



#pragma mark Call Apis By Sending JSON DATA


+(void)sendJasonDATa:(NSDictionary *)dicParameters url:(NSString*)strAPIURL Selector:(SEL )selector WithCallBackObject:(UIViewController*)objcallbackObject
{
    if (![APIsList isInternetAvailable])
    {
        return;
    }

    
    
    NSMutableDictionary *dictHeader=[[NSMutableDictionary alloc]init];
    
    [dictHeader setObject:@"application/json" forKey:@"Content-Type"];
     __block NSDictionary *dicResponse;
    
    
     [[UNIRest postEntity:^(UNIBodyRequest *request) {
         [request setUrl:strAPIURL];
         [request setHeaders:dictHeader];
         // Converting NSDictionary to JSON:
        [request setBody:[NSJSONSerialization dataWithJSONObject:dicParameters options:0 error:nil]];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
    {
        
        NSString * strResponse = [[NSString alloc] initWithData:[jsonResponse rawBody] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strResponse);
         dicResponse=jsonResponse.body.object;
        if (objcallbackObject && [objcallbackObject respondsToSelector:selector])
            [objcallbackObject performSelectorOnMainThread:selector withObject:dicResponse waitUntilDone:NO];
    }];
}



#pragma mark Call Apis with POST DATA method

+(void)callPostAsyncAPIUrl:(NSString *)url withParameter:(NSMutableDictionary *)params CallBackMethod:(SEL)selector toTarget:(UIViewController *)target showHUD:(BOOL)showHUD
{
    if (![APIsList isInternetAvailable])
    {
        return;
    }
    
    if (showHUD)
    {
        [MBProgressHUD showHUDAddedTo:target.view animated:YES];
    }
    
    [[UNIRest post:^(UNISimpleRequest* request)
    {
        [request setUrl:url];
        [request setParameters:params];
     }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error)
     {
         
         if (error)
         {
             NSLog(@"Error occure     %@",[error localizedDescription]);
         }
         
 
         
         NSString * strResponse = [[NSString alloc] initWithData:[response rawBody] encoding:NSUTF8StringEncoding];
         
         NSLog(@"Response is %@",strResponse );
         
          NSMutableDictionary *dictResponse= [strResponse JSONValue];
         dispatch_async(dispatch_get_main_queue(), ^{
              if ([target respondsToSelector:selector])
             {
                 [target performSelectorOnMainThread:selector withObject:dictResponse waitUntilDone:NO];
             }
             
             if (showHUD)
             {
                 [MBProgressHUD hideAllHUDsForView:target.view animated:YES];
             }
         });
     }];
}





#pragma mark Call Api from Appdelegate

+(void)callPostAsyncAPIFromAppdelegate_Url:(NSString *)url withParameter:(NSMutableDictionary *)params CallBackMethod:(SEL)selector toTarget:(AppDelegate *)target showHUD:(BOOL)showHUD
{
    if (![APIsList isInternetAvailable])
    {
        return;
    }
    
    if (![APIsList isInternetAvailable])
    {
        return;
    }
    
    
    
    NSMutableDictionary *dictHeader=[[NSMutableDictionary alloc]init];
    
    [dictHeader setObject:@"application/json" forKey:@"Content-Type"];
    __block NSDictionary *dicResponse;
    
    
    [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:url];
        [request setHeaders:dictHeader];
        // Converting NSDictionary to JSON:
        [request setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
     {
         
         NSString * strResponse = [[NSString alloc] initWithData:[jsonResponse rawBody] encoding:NSUTF8StringEncoding];
         NSLog(@"%@",strResponse);
         [MBProgressHUD hideAllHUDsForView:target.window animated:YES];
         dicResponse=jsonResponse.body.object;
         if (target && [target respondsToSelector:selector])
             [target performSelectorOnMainThread:selector withObject:dicResponse waitUntilDone:NO];
     }];
}







+(BOOL)isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus==NotReachable)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Internet Connection" message:@"Oops, it looks you have no internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        
        return NO;


    }
    return YES;
}



@end
