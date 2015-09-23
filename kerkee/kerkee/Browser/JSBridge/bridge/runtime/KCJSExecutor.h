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

@interface KCJSExecutor : NSObject


+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview;
//+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj;

+ (void)callJSFunctionOnMainThread:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;
+ (void)callJSOnMainThread:(NSString *)js WebView:(KCWebView*)webview;

+ (NSString *)callJSFunction:(NSString *)function withArg:(NSString *)aArg WebView:(KCWebView*)webview;
+ (NSString *)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;
+ (NSString *)callJSFunction:(NSString *)function WebView:(KCWebView*)webview;
+ (NSString *)callJS:(NSString *)js WebView:(KCWebView*)webview;


//+ (void)callbackJSWithCallbackId:(NSString *)callbackId;
+ (void)callbackJSWithCallbackId:(NSString *)callbackId WebView:(KCWebView*)webview;
+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId WebView:(KCWebView*)webview;

//+ (void)callbackJSWithCallbackId:(NSString *)callbackId jsonString:(NSString *)jsonString;
+ (void)callbackJSWithCallbackId:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview;

+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview;
+ (void)callbackJSWithCallbackId:(NSString *)callbackId string:(NSString *)string WebView:(KCWebView*)webview;
+ (void)callbackJSWithCallbackId:(NSString *)callbackId unquotedString:(NSString *)unquotedString WebView:(KCWebView*)webview;

@end
