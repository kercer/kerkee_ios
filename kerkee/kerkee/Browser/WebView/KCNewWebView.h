//
//  KCWebView.h
//  kerkee
//
//  Created by zihong on 2016/11/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKScriptMessageHandler;
@class KCNewWebView, JSContext;

@protocol KCWebViewDelegate <NSObject>
@optional

- (void)webViewDidStartLoad:(KCNewWebView*)aWebView;
- (void)webViewDidFinishLoad:(KCNewWebView*)aWebView;
- (void)webView:(KCNewWebView*)aWebView didFailLoadWithError:(NSError*)aError;
- (BOOL)webView:(KCNewWebView*)aWebView shouldStartLoadWithRequest:(NSURLRequest*)aRequest navigationType:(UIWebViewNavigationType)aNavigationType;

@end

// automatically choose to use WKWebView or UIWebView
@interface KCNewWebView : UIView

- (instancetype)initWithFrame:(CGRect)aFrame;
- (instancetype)initWithFrame:(CGRect)aFrame usingUIWebView:(BOOL)aIsUsingUIWebView; 

// Will agent to WKUIDelegate WKNavigationDelegate internal unrealized callback.
@property (weak, nonatomic) id<KCWebViewDelegate> delegate;

@property (nonatomic, readonly) id realWebView;
@property (nonatomic, readonly) BOOL isUsingUIWebView;
//Estimate the page loaded
@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, readonly) NSURLRequest* originRequest;

// Only above ios7 UIWebView can get, WKWebView please use the following method.
// ToDo integrate the two
@property (nonatomic, readonly) JSContext* jsContext;
//WKWebView interact with JS
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)aScriptMessageHandler name:(NSString*)aName;
- (void)removeScriptMessageHandlerForName:(NSString *)aName;

- (NSInteger)countOfHistory;
- (void)gobackWithStep:(NSInteger)aStep;


#pragma mark - API
@property (nonatomic, readonly) UIScrollView* scrollView;

- (id)loadRequest:(NSURLRequest*)aRequest;
- (id)loadHTMLString:(NSString*)aString baseURL:(NSURL*)aBaseURL;

@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly) NSURLRequest* currentRequest;
@property (nonatomic, readonly) NSURL* URL;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

- (id)goBack;
- (id)goForward;
- (id)reload;
- (id)reloadFromOrigin;
- (void)stopLoading;

- (void)evaluateJavaScript:(NSString*)aJavaScriptString completionHandler:(void (^)(id, NSError*))aCompletionHandler;

// default is YES
@property (nonatomic) BOOL scalesPageToFit;

@end
