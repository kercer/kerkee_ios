//
//  KCWebViewProgressDelegate.h
//  kerkee
//
//  Created by zihong on 2016/11/22.
//  Copyright © 2016年 zihong. All rights reserved.
//

#ifndef KCWebViewProgressDelegate_h
#define KCWebViewProgressDelegate_h

@class KCWebView;

@protocol KCWebViewProgressDelegate <NSObject>
@optional
-(void)webView:(id)aWebView identifierForInitialRequest:(NSURLRequest*)aInitialRequest;
-(void)webView:(id)aWebView didReceiveResourceNumber:(int)aResourceNumber totalResources:(int)aTotalResources;
-(void)webView:(id)aWebView didReceiveTitle:(NSString *)aTitle;
@end

#endif /* KCWebViewProgressDelegate_h */
