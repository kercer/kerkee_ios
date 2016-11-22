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
-(void)webView:(id)webView identifierForInitialRequest:(NSURLRequest*)initialRequest;
-(void) webView:(id)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;
@end

#endif /* KCWebViewProgressDelegate_h */
