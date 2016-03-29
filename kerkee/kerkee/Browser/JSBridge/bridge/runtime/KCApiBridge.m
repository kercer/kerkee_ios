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
#import "NSObject+KCObjectInfo.h"


static NSString *PRIVATE_SCHEME = @"kcnative";
static NSString* m_js = nil;
static BOOL sIsOpenJSLog = true;

@interface KCApiBridge ()
{
}

@property (nonatomic, assign)id m_userDelegate;


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
            NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"kerkee" ofType:@"js"];
            m_js = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:NULL];
            KCRetain(m_js);
        }
    }
    return self;
}

- (void)dealloc
{
    self.attachApiScheme = nil;
    self.m_userDelegate = nil;
    
    KCDealloc(super);
}



+ (id)apiBridgeWithWebView:(KCWebView *)aWebView delegate:(id)aUserDelegate
{
    KCApiBridge *bridge = [[KCApiBridge alloc] init];
    [bridge webviewSetting:aWebView delegate:aUserDelegate];
    
    KCAutorelease(bridge);
    return bridge;
}

- (void)webviewSetting:(KCWebView *)aWebView delegate:(id)aUserDelegate
{
    if(nil == aWebView){
        return;
    }

    if(nil != aUserDelegate){
        self.m_userDelegate = aUserDelegate;
    }
    
    aWebView.delegate = self;
    aWebView.progressDelegate = self;
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
            KCClassParser *parser = [KCClassParser createParser:jsonObj];
            
            NSString* jsClzName = [parser getJSClzName];
            NSString* methodName = [parser getJSMethodName];
            KCArgList* argList = [parser getArgList];
            //NSLog(@"value = %@",[argList getArgValule:@"callbackId"]);
            
            KCClass* kcCls = [KCRegister getClass:jsClzName];
            if (kcCls)
            {
                Class clz = [kcCls getNavClass];
                
                [kcCls addJSMethod:methodName args:argList];
                
                methodName = [NSString stringWithFormat:@"%@:argList:", methodName];
                SEL method = NSSelectorFromString(methodName);
                
                // suppress the warnings
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if(clz && [clz respondsToSelector:method])
                {
                     [clz performSelector:method withObject:webView withObject:argList];
                }
                else
                {
                    KCJSObject* receiver = [KCRegister getJSObject:jsClzName];
                    
                    if (receiver && [receiver respondsToSelector:method])
                    {
                        [receiver performSelector:method withObject:webView withObject:argList];
                    }
                }
                #pragma clang diagnostic pop
                
                
//                NSArray* methodList = [kcCls getMethods:methodName];
//                if (methodList && methodList.count > 0)
//                {
//                    KCMethod* method = methodList[0];
//                    KCLog(@"%d", method.modifier.getModifiers);
//                    if ([method isStatic])
//                    {
//                        [method invoke:clz, webView, argList, nil];
//                    }
//                    else
//                    {
//                        KCJSObject* receiver = [KCRegister getJSObject:jsClzName];
//                        [method invoke:receiver, webView, argList, nil];
//                    }
//                }
                
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

+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog
{
    sIsOpenJSLog = aIsOpenJSLog;
}

+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog
{
    sIsOpenJSLog = aIsOpenJSLog;
    if (aIsOpenJSLog)
    {
        [KCJSExecutor callJSFunction:@"jsBridgeClient.openJSLog" WebView:aWebview];
    }
    else
    {
        [KCJSExecutor callJSFunction:@"jsBridgeClient.closeJSLog" WebView:aWebview];
    }
}


+ (void)JSLog:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    KCLog(@"[JS] %@", [aArgList getObject:@"msg"]);
}


+ (void)onBridgeInitComplete:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    [aWebView documentReady:YES];
    KCJSCallback* callback = [aArgList getCallback];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[[NSNumber alloc] initWithBool:sIsOpenJSLog] forKey:@"isOpenJSLog"];
    NSString *jsonConfig = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    if (callback)
    {
        [callback callbackJS:aWebView jsonString:jsonConfig];
    }
}

+ (void)setHitPageBottomThreshold:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    NSString* strThreshold = [aArgList getString:@"threshold"];
    if (strThreshold)
    {
        float threshold = strThreshold.floatValue;
        [aWebView setHitPageBottomThreshold:threshold];
    }
}

+ (void)setPageScroll:(KCWebView*)aWebView argList:(KCArgList *)aArgList
{
    BOOL isScrollOn = [aArgList getBoolean:@"isScrollOn"];
    [aWebView setIsPageScrollOn:isScrollOn];
}

#pragma mark - 
+ (void)callbackJSOnHitPageBottom:(KCWebView*)aWebView y:(CGFloat)aY
{
    NSString* js = [NSString stringWithFormat:@"if(jsBridgeClient && jsBridgeClient.onHitPageBottom) jsBridgeClient.onHitPageBottom(%f)", aY];
    [KCJSExecutor callJSOnMainThread:js WebView:aWebView];
}

+ (void)callbackJSOnPageScroll:(KCWebView*)aWebView x:(CGFloat)aX y:(CGFloat)aY width:(CGFloat)aWidth height:(CGFloat)aHeight
{
    NSString* js = [NSString stringWithFormat:@"if(jsBridgeClient && jsBridgeClient.onPageScroll) jsBridgeClient.onPageScroll(%f,%f,%f,%f)",aX, aY, aWidth, aHeight];
    [KCJSExecutor callJSOnMainThread:js WebView:aWebView];
}


@end