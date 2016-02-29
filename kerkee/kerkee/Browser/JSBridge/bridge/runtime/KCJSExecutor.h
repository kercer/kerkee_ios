//
//  KCJSExecutor.h
//  kerkee
//
//  Created by zihong on 15/9/23.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBaseDefine.h"
#import "KCWebView.h"

#define kJSToJSONString(js) @"JSON.stringify("#js")"

@interface KCJSExecutor : NSObject


+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview;

+ (void)callJSFunctionOnMainThread:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;
+ (void)callJSOnMainThread:(NSString *)js WebView:(KCWebView*)webview;

+ (NSString *)callJSFunction:(NSString *)function withArg:(NSString *)aArg WebView:(KCWebView*)webview;
+ (NSString *)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;
+ (NSString *)callJSFunction:(NSString *)function WebView:(KCWebView*)webview;
+ (NSString *)callJS:(NSString *)js WebView:(KCWebView*)webview;


#pragma mark -
#pragma mark callbackJS
+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId;
+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId;


+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString;
+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString;

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId string:(NSString *)aString;
+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId unquotedString:(NSString *)aUnquotedString;

@end
