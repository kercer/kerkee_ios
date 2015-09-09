//
//  KCApiBridge.h
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "KCWebView.h"
#import "KCClassMrg.h"

@protocol KCApiBridgeDelegate <UIWebViewDelegate>

@optional
-(void) parseCustomApi:(NSURL*)aURL;

@end


@interface KCApiBridge : NSObject <UIWebViewDelegate,KCWebViewProgressDelegate>

//@property (nonatomic, assign) IBOutlet id <KCApiBridgeDelegate> delegate;

@property(nonatomic, strong) NSString *attachApiScheme;//附加的协议主题 需要实现parseCustomApi接口
@property(nonatomic, weak) KCWebView *m_webView;

+ (id)apiBridgeWithWebView:(KCWebView *)aWebView andDelegate:(id)userDelegate;

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


#pragma mark - register
+ (BOOL)registClass:(KCClass *)aClass;
+ (BOOL)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
+ (BOOL)registJSBridgeClient:(Class)aClass;

@end
