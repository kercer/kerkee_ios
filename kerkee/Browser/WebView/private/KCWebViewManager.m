//
//  KCWebViewManager.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCWebViewManager.h"
#import "KCBaseDefine.h"

@interface KCWebViewManager ()
{
    NSMutableDictionary* m_dicWebView;
}

@end

@implementation KCWebViewManager

DEF_SINGLETON(KCWebViewManager);

-(id)init
{
    if(self = [super init])
    {
        m_dicWebView = [[NSMutableDictionary alloc]init];
    }
    return self;
}


-(void)dealloc
{
    KCRelease(m_dicWebView);
    m_dicWebView = nil;
    KCDealloc(super);
}

-(NSString*)intToString:(NSInteger)intValue
{
    return [NSString stringWithFormat:@"%ld", (long)intValue];
}

-(void)addWithID:(NSInteger)webViewID WebView:(KCWebView*)webView
{
    [m_dicWebView setObject:webView forKey:[self intToString:webViewID]];
    KCLog(@"addWithID:WebViewID:%ld>>>>>Count:%lu", (long)webViewID, (unsigned long)m_dicWebView.count);
}

-(void)removeWithID:(NSInteger)webViewID
{
    KCLog(@"removeWithID:WebViewID:%ld>>>>>Count:%lu", (long)webViewID, (unsigned long)m_dicWebView.count);
    [m_dicWebView removeObjectForKey:[self intToString:webViewID]];
    KCLog(@"removeWithID:WebViewID:%ld>>>>>Count:%lu", (long)webViewID, (unsigned long)m_dicWebView.count);
}

-(KCWebView*)getWebViewWithID:(NSInteger)webViewID
{
    return [m_dicWebView objectForKey:[self intToString:webViewID]];
}

-(NSArray*)webViewList
{
    return [m_dicWebView allValues];
}


@end
