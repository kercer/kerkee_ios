//
//  KCJSBridge.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCJSBridge.h"
#import "KCBaseDefine.h"
#import "KCApiBridge.h"
#import "KCClass.h"

@interface KCJSBridge()
{
    KCApiBridge* m_apiBridge;
}

@property (nonatomic, weak)KCWebView *mWebView;
@end

@implementation KCJSBridge

- (id)initWithWebView:(KCWebView *)aWebView delegate:(id)delegate
{
    self = [super init];
    if(self)
    {
        _mWebView = aWebView;
        m_apiBridge = [KCApiBridge apiBridgeWithWebView:_mWebView andDelegate:delegate];
        KCRetain(m_apiBridge);
    }
    
    return self;
}

- (void)dealloc
{
    
    KCRelease(m_apiBridge);

    self.mWebView.delegate = nil;
    self.mWebView.progressDelegate = nil;
    self.mWebView = nil;
    
    KCDealloc(super);
}

/********************************************************/
/*
 * js opt
 */
/********************************************************/
#pragma mark - register
+ (BOOL)registJSBridgeClient:(Class)aClass
{
    return [KCApiBridge registJSBridgeClient:aClass];
}

+ (BOOL)registClass:(KCClass *)aClass
{
    return [KCApiBridge registClass:aClass];
}

+ (BOOL)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
{
    return [KCApiBridge registClass:aClass jsObjName:aJSObjectName];
}

#pragma mark - callJS
//
+ (void)callJSOnMainThread:(KCWebView *)aWebView jsString:(NSString *)aJS
{
    [KCApiBridge callJSOnMainThread:aJS WebView:aWebView];
}

+ (void)callJS:(KCWebView *)aWebView jsString:(NSString *)aJS
{
    [KCApiBridge callJS:aJS WebView:aWebView];
}

+ (void)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview
{
    [KCApiBridge callJSFunction:function withJSONObject:jsonObj WebView:webview];
}
+ (void)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    [KCApiBridge callJSFunction:function withJJSONString:jsonObj WebView:webview];
}
//
+ (void)callJSFunctionOnMainThread:(KCWebView *)aWebView funName:(NSString *)aFunName args:(NSString *)aArgs
{
    [KCApiBridge callJSFunctionOnMainThread:aFunName withJJSONString:aArgs WebView:aWebView];
}

//
+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId
{
    [KCApiBridge callbackJSWithCallbackId:aCallbackId WebView:aWebView];
}

+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId jsonString:(NSString *)aStr
{
    [KCApiBridge callbackJSWithCallbackId:aCallbackId jsonString:aStr WebView:aWebView];
}

/*

public static void callbackJS(KCWebView aWebview, String aCallbackId, JSONObject aJSONObject)
{
    KCApiBridge.callbackJS(aWebview, aCallbackId, aJSONObject);
}

public static void callbackJS(KCWebView aWebview, String aCallbackId, JSONArray aJSONArray)
{
    KCApiBridge.callbackJS(aWebview, aCallbackId, aJSONArray);
}
*/

/********************************************************/
/*
 *
 */
/********************************************************/
- (BOOL)isExitAsset
{
    /*
     String cfgPath = mWebView.getWebPath().getCfgPath();
     File file = new File(cfgPath);
     if (file.exists())
     return true;
     */
    return NO;
}

- (void)copyAssetHtmlDir
{
    /*
    KCAssetTool assetTool = new KCAssetTool(mWebView.getContext());
    try
    {
        assetTool.copyDir("html", mWebView.getWebPath().getResRootPath());
    }
    catch (IOException e)
    {
        e.printStackTrace();
    }
     */
}

- (KCWebView *)getWebView
{
    return _mWebView;
}

- (NSString *)getResRootPath
{
    //return mWebView == null ? null : mWebView.getWebPath().getResRootPath();
    return nil;
}


@end
