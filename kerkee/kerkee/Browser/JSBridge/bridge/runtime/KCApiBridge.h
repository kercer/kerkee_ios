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
#import "KCRegister.h"

@protocol KCApiBridgeDelegate <UIWebViewDelegate>

@optional
-(void) parseCustomApi:(NSURL*)aURL;

@end


@interface KCApiBridge : NSObject <UIWebViewDelegate,KCWebViewProgressDelegate>

@property(nonatomic, strong) NSString *attachApiScheme;//附加的协议主题 需要实现parseCustomApi接口


+ (id)apiBridgeWithWebView:(KCWebView *)aWebView delegate:(id)userDelegate;

//- (void)destroy;// destroy webview

+ (void)callbackJSOnHitPageBottom:(KCWebView*)aWebView y:(CGFloat)aY;
+ (void)callbackJSOnPageScroll:(KCWebView*)aWebView x:(CGFloat)aX y:(CGFloat)aY width:(CGFloat)aWidth height:(CGFloat)aHeight;

+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog;
+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog;

@end
