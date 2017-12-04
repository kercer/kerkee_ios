//
//  KCJSBridge.h
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
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

#pragma mark - call js use KCJSExecutor or KCJSCompileExecutor

#pragma mark - config
+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog;
+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog;

@end
