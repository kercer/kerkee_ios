//
//  KCWebView.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCWebView.h"
#import "KCJSBridge.h"
#import "KCBaseDefine.h"
#import "KCWebImageSetter.h"
#import "KCWebImageSetterTask.h"
#import "UIWebView+KCClean.h"
#import "KCApiBridge.h"
#import <objc/runtime.h>
#import "KCLog.h"


@class WebView;
@class WebScriptObject;


@interface UIWebView ()
{

}

//http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Protocols/WebFrameLoadDelegate_Protocol/Reference/Reference.html
- (void)webView:(id)sender didStartProvisionalLoadForFrame:(void *)frame;
- (void)webView:(WebView *)sender willCloseFrame:(void *)frame;
- (void)webView:(WebView *)sender didCommitLoadForFrame:(void *)frame;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(void *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(void *)frame;
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(void *)frame;
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(void *)frame;

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(void *)frame;


//http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Protocols/WebResourceLoadDelegate_Protocol/Reference/Reference.html
- (id)webView:(id)sender identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
- (NSURLRequest *)webView:(id)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource;
- (void)webView:(id)sender resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
- (void)webView:(id)sender resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

- (void)webView:(id)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(id)dataSource;
- (void)webView:(id)sender resource:(id)identifier didReceiveContentLength:(NSUInteger)length fromDataSource:(id)dataSource;


//http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Protocols/WebPolicyDelegate_Protocol/Reference/Reference.html
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(void *)frame decisionListener:(id)listener;
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id)listener;



//http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Protocols/WebUIDelegate_Protocol/Reference/Reference.html
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void *)frame;
- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(void *)frame;
- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(void *)frame;
- (void)webViewClose:(WebView *)sender;


//基类API
- (void) _updateViewSettings;
- (id) _documentView;
//- (id) _scrollView;
//- (id) _scroller;
- (id) webView;

@end


@interface KCWebView ()
{
    int m_webViewID;
    BOOL m_isDocumentReady;
    KCWebImageSetter* m_imageSetter;
    
    float m_threshold;
    BOOL m_ignoreScroll;
    
    BOOL m_isPageScrollOn;
}
@property (nonatomic,weak)id m_attach;

@end

@implementation KCWebView

@synthesize progressDelegate;
@synthesize resourceCount;
@synthesize resourceCompletedCount;


static int createWebViewID = 0;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_webViewID = createWebViewID++;
        m_imageSetter = [[KCWebImageSetter alloc] init];
        m_threshold = 0;
        m_isPageScrollOn = false;
        
//        // Add observer for scroll
//        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        m_webViewID = createWebViewID++;
        m_imageSetter = [[KCWebImageSetter alloc] init];
        m_threshold = 0;
        m_isPageScrollOn = false;
    }
    return self;
}

//#pragma mark - KVO
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"])
//    {
//         CGPoint contentOffset = self.scrollView.contentOffset;
//        
//        KCLog(@"%f, %f", contentOffset.x, contentOffset.y);
//    }
//}


- (void)dealloc
{
//    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    KCRelease(m_imageSetter);
    [self cleanForDealloc];
    
    KCDealloc(super);
}

- (id)getAttach
{
    return self.m_attach;
}

- (void)setAttach:(id)aAttch
{
    self.m_attach = aAttch;
}

- (NSString *) description
{
    NSString* des = [NSString stringWithFormat:@"<%s: %p, %@>", class_getName([self class]), self, [[[self request] URL] absoluteString]];
    KCLog(@"%@",des);
    return des;
}


//static void $UIWebViewWebViewDelegate$webView$addMessageToConsole$(id self, SEL sel, WebView *view, NSDictionary *message)
//{
//}
//
//- (void) webView:(WebView *)view addMessageToConsole:(NSDictionary *)message
//{
////    if ([self.delegate respondsToSelector:@selector(webView:addMessageToConsole:)])
////        [self.delegate webView:view addMessageToConsole:message];
//    
////    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
////        [super webView:view addMessageToConsole:message];
//}


#pragma -
#pragma mark WebFrameLoadDelegate (Frame Load Delegate Messages)
//这个委派方法是在html里面的内容被加载之前或者获得新的请求后重新加载资源之前会被调用到的，它一般会在 [[myWebView mainFrame] loadRequest:...]之后就被调用。所以适合我们在这里进行初始化工作
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(void *)frame
{
    [super webView:sender didStartProvisionalLoadForFrame:frame];
}

//当data source从provisional转换到committed时发生
//不起作用，为什么
- (void)webView:(WebView *)sender willCloseFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:willCloseFrame:)])
        [super webView:sender willCloseFrame:frame];
}

//当data source从provisional转换到committed时发生
- (void)webView:(WebView *)sender didCommitLoadForFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:didCommitLoadForFrame:)])
        [super webView:sender didCommitLoadForFrame:frame];
}

//当所有数据都以接收完成后发生
- (void)webView:(WebView *)sender didFinishLoadForFrame:(void *)frame
{
    if([UIWebView instancesRespondToSelector:@selector(webView:didFinishLoadForFrame:)])
        [super webView:sender didFinishLoadForFrame:frame];
}

//当接收到frame的标题时发生（会发生多次）
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(void *)frame
{
    if([UIWebView instancesRespondToSelector:@selector(webView:didReceiveTitle:forFrame:)])
        [super webView:sender didReceiveTitle:title forFrame:frame];
}


- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:didFailLoadWithError:forFrame:)])
        [super webView:sender didFailLoadWithError:error forFrame:frame];
}

//发生在不能接收到数据的时候，此类错误发生在诸如bad url等无法正常访问页面的情况。webView:didFailLoadWithError:forFrame发生在data source已经成为committed，但在后续获取数据时出现了错误时发生
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(void *)frame
{
    if([UIWebView instancesRespondToSelector:@selector(webView:didFailProvisionalLoadWithError:forFrame:)])
        [super webView:sender didFailProvisionalLoadWithError:error forFrame:frame];
}


//WebScript Messages

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:didClearWindowObject:forFrame:)])
        [super webView:sender didClearWindowObject:windowObject forFrame:frame];
}


#pragma mark -
#pragma mark WebResourceLoadDelegate

//Returns an identifier object used to track the progress of loading a single resource.
//when load resource,was called first，return the application-defined resource identifier
- (id)webView:(id)sender identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    
//    if([UIWebView instancesRespondToSelector:@selector(webView:identifierForInitialRequest:fromDataSource:)])
//        return [super webView:sender identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    
    
    if ([self.progressDelegate respondsToSelector:@selector(webView:identifierForInitialRequest:)])
    {
        [self.progressDelegate webView:self identifierForInitialRequest:initialRequest];
    }
    
    if([initialRequest isKindOfClass:[NSURLRequest class]])
    {
        NSURLRequest *rqt = (NSURLRequest *)initialRequest;
        if(nil != m_imageSetter)
        {
            [m_imageSetter handleImage:[KCWebImageSetterTask create:self url:rqt.URL]];
        }
    }
    
    return [NSNumber numberWithInt:resourceCount++];
}

//发生多次，在资源请求被发送之前
- (NSURLRequest *)webView:(id)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)])
    {
        request = [super webView:sender resource:identifier willSendRequest:request redirectResponse:redirectResponse fromDataSource:dataSource];
    }
    
    return request;
}

- (void)webView:(id)sender resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource
{
    [super webView:sender resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    resourceCompletedCount++;
    
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        [self.progressDelegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
    
}

//当资源的所有数据返回后发生
-(void)webView:(id)sender resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:sender resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        [self.progressDelegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
    
}

//当请求的资源返回第一个字节时发生
- (void)webView:(id)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(id)dataSource
{
    [super webView:sender resource:identifier didReceiveResponse:response fromDataSource:dataSource];
}

//发送0次或多次，直到资源的所有数据返回成功
- (void)webView:(id)sender resource:(id)identifier didReceiveContentLength:(NSUInteger)length fromDataSource:(id)dataSource
{
    [super webView:sender resource:identifier didReceiveContentLength:length fromDataSource:dataSource];
}


#pragma mark -
#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(void *)frame decisionListener:(id)listener
{
    if([UIWebView instancesRespondToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)])
    {
        [super webView:sender decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id)listener
{
    if([UIWebView instancesRespondToSelector:@selector(webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)])
        [super webView:webView decidePolicyForNewWindowAction:actionInformation request:request newFrameName:frameName decisionListener:listener];
}



#pragma mark -
#pragma mark WebUIDelegate

//实现一下shouldRunJavaScriptXX 回调出去 在此暂时不实现，注掉做个备忘

//不执行，为什么
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:)])
            [super webView:sender runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:)])
            return [super webView:sender runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame];
    return NO;
}

- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:)])
            return [super webView:sender runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame];
    return nil;
}


- (void)webViewClose:(WebView *)sender
{
    if ([UIWebView instancesRespondToSelector:@selector(webViewClose:)])
        [super webViewClose:sender];
}



#pragma mark -
#pragma mark Base API
- (void) _updateViewSettings
{
    [super _updateViewSettings];
}

-(id) _documentView
{
    return [super _documentView];
}

//- (void) dispatchEvent:(NSString *)event
//{
//    [[self _documentView] dispatchEvent:event];
//}
//
//- (void) reloadFromOrigin
//{
//    //[[[self _documentView] webView] reloadFromOrigin:nil];
//}
//
//- (UIScrollView *) scrollView
//{
//    if ([self respondsToSelector:@selector(_scrollView)])
//        return [self _scrollView];
//    else if ([self respondsToSelector:@selector(_scroller)])
//        return (UIScrollView *) [self _scroller];
//    else return nil;
//}
//
//- (void) setNeedsLayout
//{
//    [super setNeedsLayout];
//    
//    WebFrame *frame([[[self _documentView] webView] mainFrame]);
//    if ([frame respondsToSelector:@selector(setNeedsLayout)])
//        [frame setNeedsLayout];
//}


#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
//    NSString *scrollHeight = [self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    [super scrollViewDidScroll:scrollView];
//    NSLog(@"ContentOffset  x is  %f,y is %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    
    
    CGFloat scrollX = scrollView.contentOffset.x;
    CGFloat scrollY = scrollView.contentOffset.y;
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



- (void)setHitPageBottomThreshold:(float)aThreshold
{
    m_threshold = aThreshold;
}

- (void)setIsPageScrollOn:(BOOL)aIsPageScrollOn
{
    m_isPageScrollOn = aIsPageScrollOn;
}

#pragma mark -
#pragma mark api
- (int)getWebViewID
{
    return m_webViewID;
}

- (void)documentReady:(BOOL)aIsReady
{
    m_isDocumentReady = aIsReady;
}

- (BOOL)isDocumentReady
{
    return m_isDocumentReady;
}


@end



