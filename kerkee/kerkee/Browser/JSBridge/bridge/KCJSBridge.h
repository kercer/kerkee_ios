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
#import "KCRegister.h"

@interface KCJSBridge : NSObject<UIWebViewDelegate>

- (id)initWithWebView:(KCWebView *)aWebView delegate:(id)delegate;

#pragma mark - register
+ (KCClass*)registJSBridgeClient:(Class)aClass;
+ (KCClass*)registClass:(KCClass *)aClass;
+ (KCClass*)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
+ (KCClass*)registObject:(KCJSObject*)aObject;
+ (KCClass*)removeObject:(KCJSObject*)aObject;
+ (KCClass*)removeClass:(NSString*)aJSObjName;
+ (KCClass*)getClass:(NSString*)aJSObjName;

#pragma mark - callJS
+ (void)callJSOnMainThread:(KCWebView *)aWebView jsString:(NSString *)aJS;
+ (void)callJSFunctionOnMainThread:(KCWebView *)aWebView funName:(NSString *)aFunName args:(NSString *)aArgs;

+ (void)callJS:(KCWebView *)aWebView jsString:(NSString *)aJS;
+ (void)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview;
+ (void)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview;

+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId;
+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId jsonString:(NSString *)aStr;
+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId string:(NSString *)aStr;

#pragma mark - config
+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog;
+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog;

@end
