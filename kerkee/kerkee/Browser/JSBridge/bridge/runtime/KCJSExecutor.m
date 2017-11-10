//
//  KCJSExecutor.m
//  kerkee
//
//  Created by zihong on 15/9/23.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCJSExecutor.h"
#import "KCTaskQueue.h"

@implementation KCJSExecutor



#pragma mark --


/*
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
 messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
 */
+ (void)callJSFunction:(NSString*)aFunction withJSONObject:(NSDictionary*)aJsonObj inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:aJsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
    if (!json)
    {
        NSError* err = [[NSError alloc] initWithDomain:@"CallJSFunction Json Error" code:-1 userInfo:nil];
        aCompletionHandler(nil, err);
        return ;
    }
    
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", aFunction, json];
    KCAutorelease(json);
    KCAutorelease(js);
    
    if (js)
    {
        [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
    }
}
+ (void)callJSFunctionOnMainThread:(NSString*)aFunction withJSONObject:(NSDictionary*)aJsonObj inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:aJsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
    if (!json)
    {
        NSError* err = [[NSError alloc] initWithDomain:@"CallJSFunction Json Error" code:-1 userInfo:nil];
        aCompletionHandler(nil, err);
        return;
    }
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", aFunction, json];
    KCAutorelease(json);
    KCAutorelease(js);
    if (js)
    {
        FOREGROUND_BEGIN
        [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
        FOREGROUND_COMMIT
    }
}

+ (void)callJSFunctionOnMainThread:(NSString*)aFunction withJSONString:(NSString*)aJsonString inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", aFunction, aJsonString];
    if (js)
    {
        FOREGROUND_BEGIN
        [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
        FOREGROUND_COMMIT
    }
}

+ (void)callJSFunction:(NSString*)aFunction withArg:(NSString *)aArg inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", aFunction, aArg];
    KCAutorelease(js);
    [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
}

+ (void)callJSFunction:(NSString*)aFunction withJSONString:(NSString *)aJsonString inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", aFunction, aJsonString];
    KCAutorelease(js);
    [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
}

+ (void)callJSFunction:(NSString*)aFunction  inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@()", aFunction];
    KCAutorelease(js);
    [aWebView evaluateJavaScript:js completionHandler:aCompletionHandler];
}

+ (void)callJS:(NSString *)aJS inWebView:(KCWebView*)aWebView
{
    [self callJS:aJS inWebView:aWebView completionHandler:nil];
}
+ (void)callJS:(NSString*)aJS inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    [aWebView evaluateJavaScript:aJS completionHandler:aCompletionHandler];
}

+ (void)callJSOnMainThread:(NSString*)aJS inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    FOREGROUND_BEGIN
    [aWebView evaluateJavaScript:aJS completionHandler:aCompletionHandler];
    FOREGROUND_COMMIT
}


+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", aCallbackId];
    [self callJS:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", aCallbackId];
    [self callJSOnMainThread:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aJsonString];
    [self callJS:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aJsonString];
    [self callJSOnMainThread:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId string:(NSString *)aString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, '%@')", aCallbackId, aString];
    [self callJS:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId unquotedString:(NSString *)aUnquotedString;
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aUnquotedString];
    [self callJS:js inWebView:aWebview completionHandler:nil];
    KCRelease(js);
}

@end
