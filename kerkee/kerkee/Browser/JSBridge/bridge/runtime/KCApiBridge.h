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




#pragma mark - register
+ (BOOL)registClass:(KCClass *)aClass;
+ (BOOL)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
+ (BOOL)registJSBridgeClient:(Class)aClass;

@end
