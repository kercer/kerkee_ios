//
//  KCJSBridge.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCWebView.h"
#import "KCClassMrg.h"

@interface KCJSBridge : NSObject<UIWebViewDelegate>

- (id)initWithWebView:(KCWebView *)aWebView delegate:(id)delegate;

#pragma mark - register
+ (BOOL)registJSBridgeClient:(Class)aClass;
+ (BOOL)registClass:(KCClass *)aClass;
+ (BOOL)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;

#pragma mark - callJS
+ (void)callJSOnMainThread:(KCWebView *)aWebView jsString:(NSString *)aJS;
+ (void)callJSFunctionOnMainThread:(KCWebView *)aWebView funName:(NSString *)aFunName args:(NSString *)aArgs;

+ (void)callJS:(KCWebView *)aWebView jsString:(NSString *)aJS;
+ (void)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview;
+ (void)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;

+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId;
+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId jsonString:(NSString *)aStr;


@end
