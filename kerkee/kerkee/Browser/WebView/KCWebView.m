//
//  KCWebView.m
//  kerkee
//
//  Created by zihong on 2016/11/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCWebView.h"
#import <dlfcn.h>
#import <WebKit/WebKit.h>
#import <TargetConditionals.h>
#import "KCApiBridge.h"
#import "NSObject+KCSelector.h"
#import "KCWebImageSetter.h"
#import "KCWKWebView.h"
#import "UIAlertView+Blocks.h"
#import "KCUtilDevice.h"
#import "KCUtilWebView.h"


@interface KCUIWebView ()
@property (nonatomic, assign) id scrollViewDelegate;
@end

@interface KCWKWebView ()
@property (nonatomic, assign) id scrollViewDelegate;
@end

@interface KCUtilWebView ()
+ (void)setWebViewUserAgent:(NSString*)aUserAgent webView:(KCWebView*)aWebView;
@end


@interface KCWebView () <UIWebViewDelegate, KCWebViewProgressDelegate, WKNavigationDelegate, WKUIDelegate>
{
    BOOL m_isUsingUIWebView;
    id m_realWebView;
    BOOL m_scalesPageToFit;
    BOOL m_isDocumentReady;
    float m_threshold;
    BOOL m_ignoreScroll;
    BOOL m_isPageScrollOn;
    KCWebImageSetter* m_imageSetter;
    int m_webViewID;
    NSString* m_customUserAgent;
}

@property (nonatomic, assign) double estimatedProgress;
@property (nonatomic, strong) NSURLRequest* originRequest;
@property (nonatomic, strong) NSURLRequest* currentRequest;

@property (nonatomic, copy) NSString* title;

@property (nonatomic,weak)id m_attach;

@end

@implementation KCWebView

@synthesize isUsingUIWebView = m_isUsingUIWebView;
@synthesize realWebView = m_realWebView;
@synthesize scalesPageToFit = m_scalesPageToFit;

@synthesize delegate = m_delegate;
@synthesize progressDelegate = m_progressDelegate;
@synthesize customUserAgent = m_customUserAgent;


static int createWebViewID = 1;

#pragma mark - init
- (instancetype)initWithCoder:(NSCoder*)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
        [self initWebView];
    }
    return self;
}
- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
}
- (instancetype)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame usingUIWebView:NO];
}
- (instancetype)initWithFrame:(CGRect)aFrame usingUIWebView:(BOOL)aIsUsingUIWebView
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        m_isUsingUIWebView = aIsUsingUIWebView;
        [self initWebView];
    }
    return self;
}

- (void)initWebView
{
    m_webViewID = createWebViewID++;
    m_threshold = 0;
    m_isPageScrollOn = false;
    
    Class wkWebView = NSClassFromString(@"WKWebView");
    if (wkWebView && m_isUsingUIWebView == NO && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
    {
        [self initWKWebView];
        m_isUsingUIWebView = NO;
    }
    else
    {
        [self initUIWebView];
        m_isUsingUIWebView = YES;
    }
    [self.realWebView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    self.scalesPageToFit = YES;
    
    [self.realWebView setFrame:self.bounds];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.realWebView];
    
    m_imageSetter = [[KCWebImageSetter alloc] init];
}


+ (WKProcessPool *)singleWkProcessPool
{
    static dispatch_once_t once;
    static WKProcessPool * singleton;
    dispatch_once( &once, ^{ singleton = [[WKProcessPool alloc] init]; } );
    return singleton;
}

- (void)initWKWebView
{
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    
    WKPreferences* preferences = [NSClassFromString(@"WKPreferences") new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    //使用单例 解决locastorage 储存问题
    configuration.processPool = [KCWebView singleWkProcessPool];
    
    KCWKWebView* webView = [[NSClassFromString(@"KCWKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    webView.scrollViewDelegate = self;

    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;

    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    m_realWebView = webView;
}


//called after WKWebView loadRequest
- (void)observeValueForKeyPath:(NSString*)aKeyPath ofObject:(id)aObject change:(NSDictionary*)aChange context:(void*)aContext
{
    if ([aKeyPath isEqualToString:@"estimatedProgress"])
    {
        self.estimatedProgress = [aChange[NSKeyValueChangeNewKey] doubleValue];
    }
    else if ([aKeyPath isEqualToString:@"title"])
    {
        self.title = aChange[NSKeyValueChangeNewKey];
        
        if (m_progressDelegate)
        {
            if ([m_progressDelegate respondsToSelector:@selector(webView:didReceiveTitle:)])
            {
                [m_progressDelegate webView:self didReceiveTitle:self.title];
            }
        }
    }
    else
    {
        [self willChangeValueForKey:aKeyPath];
        [self didChangeValueForKey:aKeyPath];
    }
}

- (void)initUIWebView
{
    KCUIWebView* webView = [[KCUIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    
    webView.scrollViewDelegate = self;
    
    webView.opaque = NO;
    for (UIView* subview in [webView.scrollView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView*)subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }

    webView.delegate = self;
    webView.progressDelegate = self;

    m_realWebView = webView;
}
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)aScriptMessageHandler name:(NSString *)aName
{
    if (!m_isUsingUIWebView)
    {
        WKWebViewConfiguration* configuration = [(WKWebView*)self.realWebView configuration];
        [configuration.userContentController addScriptMessageHandler:aScriptMessageHandler name:aName];
    }
}
- (void)removeScriptMessageHandlerForName:(NSString *)aName
{
    if ([m_realWebView isKindOfClass:NSClassFromString(@"WKWebView")])
    {
        [[(WKWebView *)m_realWebView configuration].userContentController removeScriptMessageHandlerForName:aName];
    }
}
- (JSContext *)jsContext
{
    if (m_isUsingUIWebView)
    {
        return [(UIWebView*)self.realWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    }
    return nil;
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (self.originRequest == nil)
    {
        self.originRequest = webView.request;
    }
    [self notifyWebViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [self notifyWebViewDidStartLoad];
}
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self notifyWebViewDidFailLoadWithError:error];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self notifyWebViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return resultBOOL;
}

#pragma mark --
#pragma mark KCWebViewProgressDelegate
-(void)webView:(KCUIWebView*)aWebView identifierForInitialRequest:(NSURLRequest*)aInitialRequest
{
    if (m_progressDelegate)
    {
        if ([m_progressDelegate respondsToSelector:@selector(webView:identifierForInitialRequest:)])
        {
            [m_progressDelegate webView:self identifierForInitialRequest:aInitialRequest];
        }
    }
    
//    if([aInitialRequest isKindOfClass:[NSURLRequest class]])
//    {
//        NSURLRequest *rqt = (NSURLRequest *)aInitialRequest;
//        if(nil != m_imageSetter)
//        {
//            [m_imageSetter handleImage:[KCWebImageSetterTask create:self url:rqt.URL]];
//        }
//    }
}

-(void) webView:(KCUIWebView*)aWebView didReceiveResourceNumber:(int)aResourceNumber totalResources:(int)aTotalResources
{
    if (m_progressDelegate)
    {
        if ([m_progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
        {
            [m_progressDelegate webView:self didReceiveResourceNumber:aResourceNumber totalResources:aTotalResources];
        }
    }
}

-(void)webView:(id)aWebView didReceiveTitle:(NSString *)aTitle
{
    self.title = aTitle;
    
    if (m_progressDelegate)
    {
        if ([m_progressDelegate respondsToSelector:@selector(webView:didReceiveTitle:)])
        {
            [m_progressDelegate webView:self didReceiveTitle:aTitle];
        }
    }
}



#pragma mark - WKNavigationDelegate
/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self notifyWebViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    BOOL isLoadingDisableScheme = [self isLoadingWKWebViewDisableScheme:navigationAction.request.URL];

    if (resultBOOL && !isLoadingDisableScheme)
    {
        self.currentRequest = navigationAction.request;
        if (navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self notifyWebViewDidStartLoad];
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self notifyWebViewDidFinishLoad];
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self notifyWebViewDidFailLoadWithError:error];
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self notifyWebViewDidFailLoadWithError:error];
}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}

#pragma mark - WKUIDelegate
// TODO
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    KCButton* item1 = [KCButton buttonWithLabel:@"确定"];
    item1.action = ^
    {
        completionHandler();
    };
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message cancelButton:item1 otherButtons: nil];
    
    [alert show];
    KCRelease(alert);
    
}


#pragma mark - Notify 

#pragma mark - Notify Delegate
- (void)notifyWebViewDidFinishLoad
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)notifyWebViewDidStartLoad
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self];
    }
}
- (void)notifyWebViewDidFailLoadWithError:(NSError*)aError
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:aError];
    }
}
- (BOOL)notifyWebViewShouldStartLoadWithRequest:(NSURLRequest*)aRequest navigationType:(NSInteger)aNavigationType
{
    BOOL resultBOOL = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if (aNavigationType == -1)
        {
            aNavigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:aRequest navigationType:aNavigationType];
    }
    return resultBOOL;
}


#pragma mark - private

- (void)setDelegate:(id<KCWebViewDelegate>)aDelegate
{
    m_delegate = aDelegate;
    if (m_isUsingUIWebView)
    {
        UIWebView* webView = self.realWebView;
        webView.delegate = nil;
        webView.delegate = self;
    }
    else
    {
        WKWebView* webView = self.realWebView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
    }
}

- (BOOL)isLoadingWKWebViewDisableScheme:(NSURL*)aUrl
{
    BOOL retValue = NO;
    //WKWebview doesn't recognize the protocol type：phone numbers, email address, maps, etc.
    if ([aUrl.scheme isEqualToString:@"tel"] || [aUrl.absoluteString containsString:@"ituns.apple.com"])
    {
        UIApplication* app = [UIApplication sharedApplication];
        if ([app canOpenURL:aUrl])
        {
            [app openURL:aUrl];
            retValue = YES;
        }
    }
    return retValue;
}

#pragma mark --
- (UIScrollView*)scrollView
{
    return [(id)self.realWebView scrollView];
}

- (id)loadRequest:(NSURLRequest*)aRequest
{
    self.originRequest = aRequest;
    self.currentRequest = aRequest;

    if (m_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView loadRequest:aRequest];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadRequest:aRequest];
    }
}

- (id)loadFileURL:(NSURL *)aURL allowingReadAccessToURL:(NSURL *)aReadAccessURL
{
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:aURL];
    self.originRequest = request;
    self.currentRequest = request;
    if (m_isUsingUIWebView)
    {
        return [self loadRequest:request];
    }
    else
    {
        return [(WKWebView*)self.realWebView loadFileURL:aURL allowingReadAccessToURL:aReadAccessURL];
    }
}


- (id)loadHTMLString:(NSString*)aString baseURL:(nullable NSURL*)aBaseURL
{
    if (m_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView loadHTMLString:aString baseURL:aBaseURL];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadHTMLString:aString baseURL:aBaseURL];
    }
}
- (NSURLRequest*)currentRequest
{
    if (m_isUsingUIWebView)
    {
        return [(UIWebView*)self.realWebView request];
    }
    else
    {
        return _currentRequest;
    }
}
- (NSURL*)URL
{
    if (m_isUsingUIWebView)
    {
        return [(UIWebView*)self.realWebView request].URL;
    }
    else
    {
        return [(WKWebView*)self.realWebView URL];
    }
}

- (void)setCustomUserAgent:(NSString *)aCustomUserAgent
{
    m_customUserAgent = aCustomUserAgent;
    [KCUtilWebView setWebViewUserAgent:aCustomUserAgent webView:self];
}

- (BOOL)isLoading
{   
    return [self.realWebView isLoading];
}
- (BOOL)canGoBack
{
    return [self.realWebView canGoBack];
}
- (BOOL)canGoForward
{
    return [self.realWebView canGoForward];
}

- (id)goBack
{
    if (m_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView goBack];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goBack];
    }
}
- (id)goForward
{
    if (m_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView goForward];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goForward];
    }
}
- (id)reload
{
    if (m_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView reload];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reload];
    }
}
- (id)reloadFromOrigin
{
    if (m_isUsingUIWebView)
    {
        if (self.originRequest)
        {
            [self evaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')", self.originRequest.URL.absoluteString] completionHandler:nil];
        }
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reloadFromOrigin];
    }
}
- (void)stopLoading
{
    [self.realWebView stopLoading];
}

- (void)evaluateJavaScript:(NSString *)aJavaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError* _Nullable error))aCompletionHandler
{
    if (m_isUsingUIWebView)
    {
        NSString* result = [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:aJavaScriptString];
        if (aCompletionHandler)
        {
            aCompletionHandler(result, nil);
        }
    }
    else
    {
        return [(WKWebView*)self.realWebView evaluateJavaScript:aJavaScriptString completionHandler:aCompletionHandler];
    }
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if (m_isUsingUIWebView)
    {
        UIWebView* webView = m_realWebView;
        webView.scalesPageToFit = scalesPageToFit;
    }
    else
    {
        if (m_scalesPageToFit == scalesPageToFit)
        {
            return;
        }
        WKWebView* webView = m_realWebView;
        NSString* jScript =
        @"var head = document.getElementsByTagName('head')[0];\
        var hasViewPort = 0;\
        var metas = head.getElementsByTagName('meta');\
        for (var i = metas.length-1; i>=0 ; i--) {\
            var m = metas[i];\
            if (m.name == 'viewport') {\
                hasViewPort = 1;\
                break;\
            }\
        }; \
        if(hasViewPort == 0) { \
            var meta = document.createElement('meta'); \
            meta.name = 'viewport'; \
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
            head.appendChild(meta);\
        }";
        
        WKUserContentController *userContentController = webView.configuration.userContentController;
        NSMutableArray<WKUserScript *> *array = [userContentController.userScripts mutableCopy];
        WKUserScript* fitWKUScript = nil;
        for (WKUserScript* wkUScript in array)
        {
            if ([wkUScript.source isEqual:jScript])
            {
                fitWKUScript = wkUScript;
                break;
            }
        }
        if (scalesPageToFit)
        {
            if (!fitWKUScript)
            {
                fitWKUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
                [userContentController addUserScript:fitWKUScript];
            }
        }
        else
        {
            if (fitWKUScript)
            {
                [array removeObject:fitWKUScript];
            }
            
            [userContentController removeAllUserScripts];
            for (WKUserScript* wkUScript in array)
            {
                [userContentController addUserScript:wkUScript];
            }
        }
    }
    m_scalesPageToFit = scalesPageToFit;
}
- (BOOL)scalesPageToFit
{
    if (m_isUsingUIWebView)
    {
        return [m_realWebView scalesPageToFit];
    }
    else
    {
        return m_scalesPageToFit;
    }
}

- (NSInteger)countOfHistory
{
    if (m_isUsingUIWebView)
    {
        UIWebView* webView = self.realWebView;

        int count = [[webView stringByEvaluatingJavaScriptFromString:@"window.history.length"] intValue];
        if (count)
        {
            return count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        WKWebView* webView = self.realWebView;
        return webView.backForwardList.backList.count;
    }
}
- (void)gobackWithStep:(NSInteger)aStep
{
    if (self.canGoBack == NO)
        return;

    if (aStep > 0)
    {
        NSInteger historyCount = self.countOfHistory;
        if (aStep >= historyCount)
        {
            aStep = historyCount - 1;
        }

        if (m_isUsingUIWebView)
        {
            UIWebView* webView = self.realWebView;
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%ld)", (long)aStep]];
        }
        else
        {
            WKWebView* webView = self.realWebView;
            WKBackForwardListItem* backItem = webView.backForwardList.backList[aStep];
            [webView goToBackForwardListItem:backItem];
        }
    }
    else
    {
        [self goBack];
    }
}
#pragma mark --
//If there is no find a way to call realWebView

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if (hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if (hasResponds == NO)
    {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    return hasResponds;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
    if (methodSign == nil)
    {
        if ([self.realWebView respondsToSelector:selector])
        {
            methodSign = [self.realWebView methodSignatureForSelector:selector];
        }
        else
        {
            methodSign = [(id)self.delegate methodSignatureForSelector:selector];
        }
    }
    return methodSign;
}
- (void)forwardInvocation:(NSInvocation*)invocation
{
    if ([self.realWebView respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.realWebView];
    }
    else
    {
        [invocation invokeWithTarget:self.delegate];
    }
}

#pragma mark --
- (void)documentReady:(BOOL)aIsReady
{
    m_isDocumentReady = aIsReady;
}

- (BOOL)isDocumentReady
{
    return m_isDocumentReady;
}


- (void)setHitPageBottomThreshold:(float)aThreshold
{
    m_threshold = aThreshold;
}

- (void)setIsPageScrollOn:(BOOL)aIsPageScrollOn
{
    m_isPageScrollOn = aIsPageScrollOn;
}

- (int)getWebViewID
{
    return m_webViewID;
}

- (id)getAttach
{
    return self.m_attach;
}

- (void)setAttach:(id)aAttch
{
    self.m_attach = aAttch;
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView;
{
    CGFloat scrollX = aScrollView.contentOffset.x;
    CGFloat scrollY = aScrollView.contentOffset.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (m_isPageScrollOn)
    {
        [KCApiBridge callbackJSOnPageScroll:self x:scrollX y:scrollY width:width height:height];
    }
    
    float bottomHeight = scrollY + height;
    float contentHeight = self.scrollView.contentSize.height;
    if (scrollY >0 && height < contentHeight && bottomHeight >= contentHeight - m_threshold)
    {
        if (!m_ignoreScroll)
        {
            [KCApiBridge callbackJSOnHitPageBottom:self y:scrollY];
            m_ignoreScroll = true;
        }
    }
    else
    {
        m_ignoreScroll = false;
    }
}

#pragma mark -
- (void)dealloc
{
    KCRelease(m_imageSetter);
    m_imageSetter = nil;
    [self loadHTMLString:@"" baseURL:nil];
    
    if (m_isUsingUIWebView)
    {
        KCUIWebView* webView = m_realWebView;
        webView.delegate = nil;
        webView.scrollViewDelegate = nil;
    }
    else
    {
        KCWKWebView* webView = m_realWebView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        webView.scrollViewDelegate = nil;

        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [webView removeObserver:self forKeyPath:@"title"];
    }
    [m_realWebView removeObserver:self forKeyPath:@"loading"];
    [m_realWebView scrollView].delegate = nil;
    [m_realWebView stopLoading];
    [(UIWebView*)m_realWebView loadHTMLString:@"" baseURL:nil];
    [m_realWebView stopLoading];
    [m_realWebView removeFromSuperview];
    m_realWebView = nil;
    m_progressDelegate = nil;
    m_delegate = nil;
    
    KCDealloc(super);
}
@end
