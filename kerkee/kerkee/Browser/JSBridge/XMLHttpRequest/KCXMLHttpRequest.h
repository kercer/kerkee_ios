//
//  KCXMLHttpRequest.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "KCXMLHttpRequestDelegate.h"
#import "KCWebView.h"

@interface KCXMLHttpRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, assign) id delegate;

- (id)initWithObjectId:(NSNumber *)objectId WebView:(KCWebView*)webview;

- (void)open:(NSString *)method url:(NSString *)url userAgent:(NSString *)userAgent referer:(NSString*)referer cookie:(NSString *)cookie;
- (void)send;
- (void)send:(NSString *)data;
- (void)setRequestHeader:(NSString *)headerName headerValue:(NSString *)headerValue;
- (void)overrideMimeType:(NSString *)mimeType;
- (BOOL)isOpened;
- (void)abort;

-(NSNumber*)objectId;
-(NSURLRequest*)request;
-(BOOL)isGetMethod;
-(KCWebView*)webview;

@end
