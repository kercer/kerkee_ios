//
//  KCXMLHttpRequestDispatcher.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "KCXMLHttpRequestDelegate.h"
#import "KCWebView.h"
#import "KCArgList.h"
#import "KCJSObject.h"

@class KCXMLHttpRequest;

@interface KCXMLHttpRequestDispatcher : KCJSObject

- (KCXMLHttpRequest *)create:(KCWebView*)aWebView argList:(KCArgList *)args;

- (void)open:(KCWebView*)aWebView argList:(KCArgList *)args;
- (void)send:(KCWebView*)aWebView argList:(KCArgList *)args;
- (void)setRequestHeader:(KCWebView*)aWebView argList:(KCArgList *)args;
- (void)overrideMimeType:(KCWebView*)aWebView argList:(KCArgList *)args;
- (void)abort:(KCWebView*)aWebView argList:(KCArgList *)args;

@end
