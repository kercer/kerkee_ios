//
//  KCJSExecutor.m
//  kerkee
//
//  Created by zihong on 15/9/23.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCJSExecutor.h"


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
+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview
{
    NSString* result = @"";
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
    if (!json) return result;
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, json];
    KCAutorelease(json);
    KCAutorelease(js);
    if (js)
        result = [webview stringByEvaluatingJavaScriptFromString:js];
    return result;
}


+ (void)callJSFunctionOnMainThread:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj];
    [webview performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

+ (NSString *)callJSFunction:(NSString *)function withArg:(NSString *)aArg WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, aArg];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)callJSFunction:(NSString *)function WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@()", function];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)callJS:(NSString *)js WebView:(KCWebView*)webview
{
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (void)callJSOnMainThread:(NSString *)js WebView:(KCWebView*)webview
{
    [webview performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}


+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", aCallbackId];
    [self callJS:js WebView:aWebview];
    KCRelease(js);
}

+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", aCallbackId];
    [self callJSOnMainThread:js WebView:aWebview];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aJsonString];
    [self callJS:js WebView:aWebview];
    KCRelease(js);
}

+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aJsonString];
    [self callJSOnMainThread:js WebView:aWebview];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId string:(NSString *)aString
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, \"%@\")", aCallbackId, aString];
    [self callJS:js WebView:aWebview];
    KCRelease(js);
}

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId unquotedString:(NSString *)aUnquotedString;
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", aCallbackId, aUnquotedString];
    [self callJS:js WebView:aWebview];
    KCRelease(js);
}

@end
