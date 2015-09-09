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


+ (id)apiBridgeWithWebView:(KCWebView *)aWebView andDelegate:(id)userDelegate
{
    //KCApiBridge *bridge = [KCApiBridge sharedInstance];
    
    KCApiBridge *bridge = [[KCApiBridge alloc] init];
    [bridge setCurrentWebView:aWebView andDelegate:userDelegate];
    
    KCAutorelease(bridge);
    return bridge;
}

- (void)setCurrentWebView:(KCWebView *)webView andDelegate:(id)userDelegate
{
    if(nil == webView){
        return;
    }

    if(nil != userDelegate){
        self.m_userDelegate = userDelegate;
    }
    
    self.m_webView = webView;
    self.m_webView.delegate = self;
    self.m_webView.progressDelegate = self;
}


#pragma mark UIWebViewDelegate

- (BOOL)webView:(KCWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:PRIVATE_SCHEME])
    {
        [KCApiBridge callJS:@"ApiBridge.prepareProcessingMessages()" WebView:webView];
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
            
            /*
            NSString *className = [s_classMap objectForKey:[jsonObj objectForKey:@"clz"]];
            if (className)
            {
                Class clz = NSClassFromString(className);
                NSString* methodStr = [jsonObj objectForKey:@"method"];
                if (!methodStr) continue;
                
                NSRange range = [methodStr rangeOfString:@":"];
                if (range.length == 0)
                {
                    methodStr = [NSString stringWithFormat:@"%@:argList:", methodStr];
                    KCLog(@"method >> %@", methodStr);
                }
                
                SEL method = NSSelectorFromString(methodStr);
//                if (method != @selector(JSLog:))
//                {
//                    KCLog(@"[OBJC] - %@ = %@", className, [jsonObj objectForKey:@"method"]);
//                }
                if (clz && [clz respondsToSelector:method])
                {
//                    if (method != @selector(JSLog:))
//                    {
//                        KCLog(@"[OBJC] - √ %@ = %@", className, [jsonObj objectForKey:@"method"]);
//                    }
                    NSDictionary *args = [jsonObj objectForKey:@"args"];
                    // suppress the warnings
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if (args)
                    {
                        [clz performSelector:method withObject:webView withObject:args];
                    }
                    else
                    {
                        [clz performSelector:method];
                    }
                    #pragma clang diagnostic pop
                    
                }
                
            }
            */
        }
    }
}


- (NSArray *)fetchJSONMessagesFromJSSide:(KCWebView *)webview
{
    NSString *jsonStrMsg = [KCApiBridge callJS:@"ApiBridge.fetchMessages()" WebView:webview];

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

    [KCApiBridge callbackJSWithCallbackId:callbackId WebView:aWebView];
}

#pragma mark --


/*
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
*/
+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview
{
    //NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj.JSONString];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, json];
    KCAutorelease(json);
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}


//+ (NSString *)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj
//{
//    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil] encoding:NSUTF8StringEncoding];
//    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, json];
//    return [[KCApiBridge sharedInstance].m_webView stringByEvaluatingJavaScriptFromString:js];
//}


+ (void)callJSFunctionOnMainThread:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj];
    [webview performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

+ (NSString *)callJSFunction:(NSString *)function withArg:(NSString *)aArg WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, aArg];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@(%@)", function, jsonObj];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)callJSFunction:(NSString *)function WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"%@()", function];
    KCAutorelease(js);
    return [webview stringByEvaluatingJavaScriptFromString:js];    
}

+ (NSString *)callJS:(NSString *)js WebView:(KCWebView*)webview
{
    return [webview stringByEvaluatingJavaScriptFromString:js];
}

+ (void)callJSOnMainThread:(NSString *)js WebView:(KCWebView*)webview
{
   [webview performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

//+ (void)callbackJSWithCallbackId:(NSString *)callbackId
//{
//    if(nil != [KCApiBridge sharedInstance].m_webView)
//    {
//        [KCApiBridge callbackJSWithCallbackId:callbackId  WebView:[KCApiBridge sharedInstance].m_webView];
//    }
//}
+ (void)callbackJSWithCallbackId:(NSString *)callbackId WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", callbackId];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@)", callbackId];
    [self callJSOnMainThread:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, jsonString];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackIdOnMainThread:(NSString *)callbackId jsonString:(NSString *)jsonString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, jsonString];
    [self callJSOnMainThread:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId string:(NSString *)string WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, \"%@\")", callbackId, string];
    [self callJS:js WebView:webview];
    KCRelease(js);
}

+ (void)callbackJSWithCallbackId:(NSString *)callbackId unquotedString:(NSString *)unquotedString WebView:(KCWebView*)webview
{
    NSString *js = [[NSString alloc] initWithFormat:@"ApiBridge.onCallback(%@, %@)", callbackId, unquotedString];
    [self callJS:js WebView:webview];
    KCRelease(js);
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