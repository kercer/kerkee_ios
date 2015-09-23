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
    //NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj.JSONString];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, json];
    KCAutorelease(json);
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}


//+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj
//{
//    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
//    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, json];
//    return [[KCApiBridge sharedInstance].m_webView stringByEvaluatingJavaScriptFromString:js];
//}


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

//+ (void)callbackJSWithCallbackId:(NSString *)callbackId
//{
//    if(nil != [KCApiBridge sharedInstance].m_webView)
//    {
//        [KCApiBridge callbackJSWithCallbackId:callbackId  WebView:[KCApiBridge sharedInstance].m_webView];
//    }
//}
+ (void)callbackJSWithCallbackId:(NSString *)callbackId WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", callbackId];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", callbackId];
    [self callJSOnMainThread:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, jsonString];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, jsonString];
    [self callJSOnMainThread:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId string:(NSString *)string WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, \"%@\")", callbackId, string];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId unquotedString:(NSString *)unquotedString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, unquotedString];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

@end
