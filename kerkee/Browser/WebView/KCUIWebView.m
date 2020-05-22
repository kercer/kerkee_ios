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
#import "NSObject+KCSelector.h"


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


//super API
- (void) _updateViewSettings;
- (id) _documentView;
//- (id) _scrollView;
//- (id) _scroller;
- (id) webView;

@end


@interface KCUIWebView ()
{
    
}

@property (nonatomic, weak) id scrollViewDelegate;

@end

@implementation KCUIWebView

@synthesize progressDelegate;
@synthesize resourceCount;
@synthesize resourceCompletedCount;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
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
    
    [self kc_cleanForDealloc];
    self.scrollViewDelegate = nil;
    
    KCDealloc(super);
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
//The delegate method is inside the HTML content is loaded before or get a new request to reload after resources will be called to the before, which typically in [[myWebView mainFrame] loadRequest:...And then be invoked.So are suitable for initialized we are here to work
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(void *)frame
{
    [super webView:sender didStartProvisionalLoadForFrame:frame];
}

//When the data source from the provisional to committed to occur
//why?
- (void)webView:(WebView *)sender willCloseFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:willCloseFrame:)])
        [super webView:sender willCloseFrame:frame];
}

//When the data source from the provisional to committed to occur
- (void)webView:(WebView *)sender didCommitLoadForFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:didCommitLoadForFrame:)])
        [super webView:sender didCommitLoadForFrame:frame];
}

//When after completion of all data to receive
- (void)webView:(WebView *)sender didFinishLoadForFrame:(void *)frame
{
    if([UIWebView instancesRespondToSelector:@selector(webView:didFinishLoadForFrame:)])
        [super webView:sender didFinishLoadForFrame:frame];
}

//Occurs when the title of the received frame (happens many times)
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(void *)frame
{
    if([UIWebView instancesRespondToSelector:@selector(webView:didReceiveTitle:forFrame:)])
        [super webView:sender didReceiveTitle:title forFrame:frame];
    
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveTitle:)])
    {
        [self.progressDelegate webView:self didReceiveTitle:title];
    }
}


- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(void *)frame
{
    if ([UIWebView instancesRespondToSelector:@selector(webView:didFailLoadWithError:forFrame:)])
        [super webView:sender didFailLoadWithError:error forFrame:frame];
}

//Happen when cannot receive data, this kind of error occurred in such as bad url to access the page.WebView: didFailLoadWithError: forFrame occurred in data source has been committed, but in the subsequent appeared when get the data error occurs
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
    
    return [NSNumber numberWithInt:resourceCount++];
}

//Happened many times, before the resource request is sent
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

//When resources are all of the data returned
-(void)webView:(id)sender resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:sender resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        [self.progressDelegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
    
}

//When resources are all of the data returned
- (void)webView:(id)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(id)dataSource
{
    [super webView:sender resource:identifier didReceiveResponse:response fromDataSource:dataSource];
}

//Send 0 or more times, until all data resources return success
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

//not call,why?
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
#pragma mark api



#pragma mark -
#pragma mark UIScrollViewDelegate

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([UIWebView instancesRespondToSelector:@selector(scrollViewDidScroll:)])
        [super scrollViewDidScroll:scrollView];
    if (self.scrollViewDelegate)
    {
        [self.scrollViewDelegate kc_performSelectorSafetyWithArgs:@selector(scrollViewDidScroll:), scrollView, nil];
    }
}


@end



