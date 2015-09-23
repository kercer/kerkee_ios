//
//  KCApiBridge.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCApiBridge.h"
#import "KCBaseDefine.h"
#import "KCLog.h"
#import "KCJSDefine.h"
#import "KCClassParser.h"
#import "KCSingleton.h"
#import "KCBaseDefine.h"
#import "KCWebPathDefine.h"
#import "KCJSExecutor.h"
#import "NSObject+KCSelector.h"


static NSString *PRIVATE_SCHEME = @"kcnative";
static NSString* m_js = nil;

@interface KCApiBridge ()


@property (nonatomic, assign)id m_userDelegate;

//AS_SINGLETON(KCApiBridge);

/* notified when a message is pushed/delievered on the JS side */
- (void) onNotified:(KCWebView *)webView;
- (NSArray *) fetchJSONMessagesFromJSSide:(KCWebView *)webView;

@end

@implementation KCApiBridge

//@synthesize delegate = _delegate;
@synthesize attachApiScheme;


-(id)init;
{
    if(self = [super init])
    {
        if(!m_js)
        {
            NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"bridgeLib" ofType:@"js"];
            m_js = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:NULL];
//            m_js = [NSString stringWithContentsOfFile:KCWebPath_BridgeLibPath_File encoding:NSUTF8StringEncoding error:NULL];
            KCRetain(m_js);
        }
    }
    return self;
}

- (void)dealloc
{
    self.m_webView.delegate = nil;
    self.m_webView.progressDelegate = self;
    
    self.m_webView = nil;
    self.attachApiScheme = nil;
    self.m_userDelegate = nil;
    
    KCDealloc(super);
}


+ (id)apiBridgeWithWebView:(KCWebView *)aWebView delegate:(id)aUserDelegate
{
    //KCApiBridge *bridge = [KCApiBridge sharedInstance];
    
    KCApiBridge *bridge = [[KCApiBridge alloc] init];
    [bridge setCurrentWebView:aWebView delegate:aUserDelegate];
    
    KCAutorelease(bridge);
    return bridge;
}

- (void)setCurrentWebView:(KCWebView *)aWebView delegate:(id)aUserDelegate
{
    if(nil == aWebView){
        return;
    }

    if(nil != aUserDelegate){
        self.m_userDelegate = aUserDelegate;
    }
    
    self.m_webView = aWebView;
    self.m_webView.delegate = self;
    self.m_webView.progressDelegate = self;
}


#pragma mark --
#pragma mark KCWebViewProgressDelegate
-(void)webView:(KCWebView*)aWebView identifierForInitialRequest:(NSURLRequest*)aInitialRequest
{
    if (self.m_userDelegate)
        [self.m_userDelegate performSelectorSafetyWithArgs:@selector(webView:identifierForInitialRequest:), aWebView, aInitialRequest, nil];
}

-(void) webView:(KCWebView*)aWebView didReceiveResourceNumber:(int)aResourceNumber totalResources:(int)aTotalResources
{
    if (self.m_userDelegate)
        [self.m_userDelegate performSelectorSafetyWithArgs:@selector(webView:didReceiveResourceNumber:totalResources:), aWebView, aResourceNumber, aTotalResources, nil];
}


#pragma mark --
#pragma mark UIWebViewDelegate

- (BOOL)webView:(KCWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:PRIVATE_SCHEME])
    {
        [KCJSExecutor callJS:@"ApiBridge.prepareProcessingMessages()" WebView:webView];
        [self onNotified:webView];
    }
    /*
    else if (attachApiScheme && [request.URL.scheme isEqualToString:attachApiScheme])
    {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parseCustomApi:)])
        {
            [self.delegate parseCustomApi:request.URL];
        }
    }
    */

    if (self.m_userDelegate != nil && [self.m_userDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        return [self.m_userDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    return NO;
}

- (void)webViewDidStartLoad:(KCWebView *)webView
{
    if(self.m_userDelegate != nil && [self.m_userDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.m_userDelegate webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(KCWebView *)webView
{    
    if (m_js !=nil && ![[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJSBridge == 'object'"] isEqualToString:@"true"])
    {
        [webView stringByEvaluatingJavaScriptFromString:m_js];
    }
    
    if(self.m_userDelegate != nil && [self.m_userDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.m_userDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(KCWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(self.m_userDelegate != nil && [self.m_userDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.m_userDelegate webView:webView didFailLoadWithError:error];
    }
}


- (void)onNotified:(KCWebView *)webView
{
    NSArray *jsonMessages;
    while ((jsonMessages = [self fetchJSONMessagesFromJSSide:webView]))
    {
//        KCLog(@"%@", jsonMessages);
        for (NSDictionary *jsonObj in jsonMessages)
        {
            KCClassParser *parser = [KCClassParser initWithDictionary:jsonObj];
            
            NSString *clsName = [parser getJSClzName];
            NSString *methodName = [parser getJSMethodName];
            KCArgList *argList = [parser getArgList];
            //NSLog(@"value = %@",[argList getArgValule:@"callbackId"]);
            
            KCClass *kcCls = [KCClassMrg getClass:clsName];
            {
                Class clz = [kcCls getNavClass];
                
                [kcCls addMethod:methodName args:argList];
                
                if([argList count] > 0)
                {
                    methodName = [NSString stringWithFormat:@"%@:argList:", methodName];
                }
                
                SEL method = NSSelectorFromString(methodName);
                
                // suppress the warnings
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if(clz && [clz respondsToSelector:method])
                {
                     [clz performSelector:method withObject:webView withObject:argList];
                }
                #pragma clang diagnostic pop
                
                //KCLog(@"method ---------------------> %@", methodName);
            }
            
        }
    }
}


- (NSArray *)fetchJSONMessagesFromJSSide:(KCWebView *)webview
{
    NSString *jsonStrMsg = [KCJSExecutor callJS:@"ApiBridge.fetchMessages()" WebView:webview];

    if (jsonStrMsg && [jsonStrMsg length] > 0)
    {
        //KCLog(@"jsonMsg----:\n%@",jsonStrMsg);
        return [NSJSONSerialization JSONObjectWithData:[jsonStrMsg dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    }
    
    return nil;
}

#pragma mark --

+ (void)JSLog:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    KCLog(@"[JS] - %@", [aArgList getArgValule:@"msg"]);
}


+ (void)onBridgeInitComplete:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    [aWebView documentReady:YES];
    NSString* callbackId = [aArgList getArgValule:kJS_callbackId];

    [KCJSExecutor callbackJSWithCallbackId:callbackId WebView:aWebView];
}



#pragma mark - register
+ (BOOL)registClass:(KCClass *)aClass
{
    return [KCClassMrg registClass:aClass];
}

+ (BOOL)registClass:(Class )aClass jsObjName:(NSString *)aJSObjectName
{
    return [KCClassMrg registClass:aClass withJSObjName:aJSObjectName];
}

+ (BOOL)registJSBridgeClient:(Class)aClass
{
    [KCClassMrg removeClass:kJS_jsBridgeClient];
    return [KCClassMrg registClass:aClass withJSObjName:kJS_jsBridgeClient];
}


@end