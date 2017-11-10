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

NS_ASSUME_NONNULL_BEGIN

@interface KCJSExecutor : NSObject


+ (void)callJSFunction:(NSString *)aFunction withJSONObject:(NSDictionary *)aJsonObj inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSFunctionOnMainThread:(NSString *)aFunction withJSONObject:(NSDictionary *)aJsonObj inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSFunctionOnMainThread:(NSString *)aFunction withJSONString:(NSString *)aJsonString inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSFunction:(NSString *)aFunction withArg:(NSString *)aArg inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSFunction:(NSString *)aFunction withJSONString:(NSString *)aJsonString inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSFunction:(NSString *)aFunction  inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJS:(NSString *)aJS inWebView:(KCWebView*)aWebView;
+ (void)callJS:(NSString *)aJS inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

+ (void)callJSOnMainThread:(NSString*)aJS inWebView:(KCWebView*)aWebView completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;


#pragma mark -
#pragma mark callbackJS
+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId;
+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId;

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString;
+ (void)callbackJSOnMainThread:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId jsonString:(NSString *)aJsonString;

+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId string:(NSString *)aString;
+ (void)callbackJS:(KCWebView*)aWebview callbackId:(NSString *)aCallbackId unquotedString:(NSString *)aUnquotedString;

@end

NS_ASSUME_NONNULL_END
