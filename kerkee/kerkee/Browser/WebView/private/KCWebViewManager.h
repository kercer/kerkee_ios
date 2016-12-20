//
//  KCWebViewManager.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KCSingleton.h"
#import "KCWebView.h"

@interface KCWebViewManager : NSObject

AS_SINGLETON(KCWebViewManager);


-(void)addWithID:(NSInteger)webViewID WebView:(KCWebView*)webView;
-(void)removeWithID:(NSInteger)webViewID;
-(KCWebView*)getWebViewWithID:(NSInteger)webViewID;

-(NSArray*)webViewList;

@end
