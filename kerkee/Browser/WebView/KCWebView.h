//
//  KCWebView.h
//  kerkee
//
//  Created by zihong on 2016/11/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCUIWebView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WKScriptMessageHandler;
@class KCWebView, JSContext;

@protocol KCWebViewDelegate <NSObject>
@optional

- (void)webViewDidStartLoad:(KCWebView*)aWebView;
- (void)webViewDidFinishLoad:(KCWebView*)aWebView;
- (void)webView:(KCWebView*)aWebView didFailLoadWithError:(NSError*)aError;
- (BOOL)webView:(KCWebView*)aWebView shouldStartLoadWithRequest:(NSURLRequest*)aRequest navigationType:(UIWebViewNavigationType)aNavigationType;

@end

// automatically choose to use WKWebView or UIWebView
@interface KCWebView : UIView

- (instancetype)initWithFrame:(CGRect)aFrame;
- (instancetype)initWithFrame:(CGRect)aFrame usingUIWebView:(BOOL)aIsUsingUIWebView;

- (instancetype)initWithFrame:(CGRect)aFrame usingUIWebView:(BOOL)aIsUsingUIWebView configuration:(id)configuration;

@property (nonatomic, readonly) id realWebView;

// Will agent to WKUIDelegate WKNavigationDelegate internal unrealized callback.
@property (weak, nonatomic) id<KCWebViewDelegate> delegate;

@property (weak, nonatomic) id<KCWebViewProgressDelegate> progressDelegate;

@property (nonatomic, readonly) BOOL isUsingUIWebView;
//Estimate the page loaded
@property (nonatomic, readonly) double estimatedProgress;

// Only above ios7 UIWebView can get, WKWebView please use the following method.
// ToDo integrate the two
@property (nonatomic, readonly) JSContext* jsContext;
//WKWebView interact with JS
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)aScriptMessageHandler name:(NSString*)aName;
- (void)removeScriptMessageHandlerForName:(NSString *)aName;

- (NSInteger)countOfHistory;
- (void)gobackWithStep:(NSInteger)aStep;

//@property (nonatomic, readonly) NSString* originUserAgent;



#pragma mark - API
@property (nonatomic, readonly) UIScrollView* scrollView;

- (id)loadRequest:(NSURLRequest*)aRequest;
- (id)loadFileURL:(NSURL *)aURL allowingReadAccessToURL:(NSURL *)aReadAccessURL API_AVAILABLE(macosx(10.11), ios(9.0));
- (id)loadHTMLString:(NSString*)aString baseURL:(nullable NSURL*)aBaseURL;

@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly) NSURLRequest* originRequest;
@property (nonatomic, readonly) NSURLRequest* currentRequest;
@property (nonatomic, readonly) NSURL* URL;

/*! @abstract The custom user agent string or nil if no custom user agent string has been set.
 */
@property (nullable, nonatomic, copy) NSString *customUserAgent;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

- (id)goBack;
- (id)goForward;
- (id)reload;
- (id)reloadFromOrigin;
- (void)stopLoading;

#pragma mark --
- (void)documentReady:(BOOL)aIsReady;
- (BOOL)isDocumentReady;
- (void)setHitPageBottomThreshold:(float)aThreshold;
- (void)setIsPageScrollOn:(BOOL)aIsPageScrollOn;

- (int)getWebViewID;
- (id)getAttach;
- (void)setAttach:(id)aAttch;

/* @abstract Evaluates the given JavaScript string.
 @param javaScriptString The JavaScript string to evaluate.
 @param completionHandler A block to invoke when script evaluation completes or fails.
 @discussion The completionHandler is passed the result of the script evaluation or an error.
 */
- (void)evaluateJavaScript:(NSString *)aJavaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

// default is YES
@property (nonatomic) BOOL scalesPageToFit;

@end

NS_ASSUME_NONNULL_END
