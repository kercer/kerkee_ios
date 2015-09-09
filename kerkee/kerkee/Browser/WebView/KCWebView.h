//
//  KCWebView.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <UIKit/UIKit.h>

@class KCXMLHttpRequest;
@class KCWebView;

@protocol KCWebViewProgressDelegate <NSObject>
@optional
-(void)webView:(KCWebView*)webView identifierForInitialRequest:(NSURLRequest*)initialRequest;
-(void) webView:(KCWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;
@end

@interface KCWebView : UIWebView
{
    
}

@property (nonatomic,weak)KCXMLHttpRequest *xmlRequest;

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;

@property (nonatomic, assign) IBOutlet id<KCWebViewProgressDelegate> progressDelegate;

- (int)getWebViewID;
- (void)documentReady:(BOOL)aIsReady;
- (BOOL)isDocumentReady;

- (id)getAttach;
- (void)setAttach:(id)aAttch;

@end
