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
#import "KCJSExecutor.h"
#import "KCJSDefine.h"

@interface KCJSBridge()
{
    KCApiBridge* m_apiBridge;
}

@end

@implementation KCJSBridge

- (id)initWithWebView:(KCWebView *)aWebView delegate:(id)delegate
{
    self = [super init];
    if(self)
    {
        m_apiBridge = [KCApiBridge apiBridgeWithWebView:aWebView delegate:delegate];
        KCRetain(m_apiBridge);
    }
    
    return self;
}

- (void)dealloc
{
    
    KCRelease(m_apiBridge);
    
    KCDealloc(super);
}

/********************************************************/
/*
 * js opt
 */
/********************************************************/
#pragma mark - register
+ (KCClass*)registJSBridgeClient:(Class)aClass
{
    return [KCRegister registClass:aClass withJSObjName:kJS_jsBridgeClient];
}

+ (KCClass*)registClass:(KCClass *)aClass
{
    return [KCRegister registClass:aClass];
}

+ (KCClass*)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
{
    return [KCRegister registClass:aClass withJSObjName:aJSObjectName];
}

+ (KCClass*)registObject:(KCJSObject*)aObject
{
    return [KCRegister registObject:aObject];
}
+ (KCClass*)removeObject:(KCJSObject*)aObject
{
    return [KCRegister removeObject:aObject];
}

+ (KCClass*)removeClass:(NSString*)aJSObjName
{
    return [KCRegister removeClass:aJSObjName];
}

+ (KCClass*)getClass:(NSString*)aJSObjName
{
    return [KCRegister getClass:aJSObjName];
}


/********************************************************/
/*
 * js call
 */
/********************************************************/

#pragma mark - callJS

+ (void)callJSOnMainThread:(KCWebView *)aWebView jsString:(NSString *)aJS
{
    [KCJSExecutor callJSOnMainThread:aJS WebView:aWebView];
}

+ (void)callJS:(KCWebView *)aWebView jsString:(NSString *)aJS
{
    [KCJSExecutor callJS:aJS WebView:aWebView];
}

+ (void)callJSFunction:(NSString *)function withJSONObject:(NSDictionary *)jsonObj WebView:(KCWebView*)webview
{
    [KCJSExecutor callJSFunction:function withJSONObject:jsonObj WebView:webview];
}
+ (void)callJSFunction:(NSString *)function withJJSONString:(NSString *)jsonObj WebView:(KCWebView*)webview
{
    [KCJSExecutor callJSFunction:function withJJSONString:jsonObj WebView:webview];
}
//
+ (void)callJSFunctionOnMainThread:(KCWebView *)aWebView funName:(NSString *)aFunName args:(NSString *)aArgs
{
    [KCJSExecutor callJSFunctionOnMainThread:aFunName withJJSONString:aArgs WebView:aWebView];
}

//
+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId
{
    [KCJSExecutor callbackJS:aWebView callbackId:aCallbackId];
}

+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId jsonString:(NSString *)aStr
{
    [KCJSExecutor callbackJS:aWebView callbackId:aCallbackId jsonString:aStr];
}

+ (void)callbackJS:(KCWebView *)aWebView callBackID:(NSString *)aCallbackId string:(NSString *)aStr
{
    [KCJSExecutor callbackJS:aWebView callbackId:aCallbackId string:aStr];
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
 * config
 */
/********************************************************/
+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog
{
    [KCApiBridge openGlobalJSLog:aIsOpenJSLog];
}

+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog
{
    [KCApiBridge setIsOpenJSLog:aWebview isOpenJSLog:aIsOpenJSLog];
}


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


- (NSString *)getResRootPath
{
    //return mWebView == null ? null : mWebView.getWebPath().getResRootPath();
    return nil;
}


@end
