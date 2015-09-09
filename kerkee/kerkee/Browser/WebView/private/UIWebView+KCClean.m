//
//  UIWebView+KCClean.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "UIWebView+KCClean.h"

@implementation UIWebView (clean)



/*
 
 #1: UIWebViewDelegate:
 
 - (void) webViewDidFinishLoad:(UIWebView *)webView
 {
 //source: http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part1-memory-leaks-on-xmlhttprequest/
 [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
 }
 
 #2:
 
 - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
 {
 // http://stackoverflow.com/questions/6421813/lots-of-uiwebview-memory-leaks
 return YES;
 }
 
 #3: Some leaks appear to be fixed in IOS 4.1
 Source: http://stackoverflow.com/questions/3857519/memory-leak-while-using-uiwebview-load-request-in-ios4-0
 
 #4: When you create your UIWebImageView, disable link detection if possible:
 
 webView.dataDetectorTypes = UIDataDetectorTypeNone;
 
 (This is also the "Detect Links" checkbox on a UIWebView in Interfacte Builder.)
 
 Sources:
 http://www.iphonedevsdk.com/forum/iphone-sdk-development/46260-how-free-memory-after-uiwebview.html
 http://www.iphonedevsdk.com/forum/iphone-sdk-development/29795-uiwebview-how-do-i-stop-detecting-links.html
 http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part2-leaks-on-release/
 
 #5: Consider cleaning the NSURLCache every so often:
 
 [[NSURLCache sharedURLCache] removeAllCachedResponses];
 [[NSURLCache sharedURLCache] setDiskCapacity:0];
 [[NSURLCache sharedURLCache] setMemoryCapacity:0];
 
 Source: http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part2-leaks-on-release/
 
 Be careful with this, as it may kill cache objects for currently executing URL
 requests for your application, if you can't cleanly clear the whole cache in
 your app in some place where you expect zero URLRequest to be executing, use
 the following instead after you are done with each request (note that you won't
 be able to do this w/ UIWebView's internal request objects..):
 
 [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
 
 Source: http://stackoverflow.com/questions/6542114/clearing-a-webviews-cache-for-local-files
 
 */

- (void) cleanForDealloc
{
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    self.delegate = nil;
    [self removeFromSuperview];
}

@end
