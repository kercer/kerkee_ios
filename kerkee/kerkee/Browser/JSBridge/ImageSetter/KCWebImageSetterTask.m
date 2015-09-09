//
//  KCWebImageSetterTask.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCWebImageSetterTask.h"
#import "KCBaseDefine.h"

@interface KCWebImageSetterTask ()
{
    KCWebView* m_webView;
    NSURL* m_url;

}
@end

@implementation KCWebImageSetterTask


- (id)initWithWebView:(KCWebView *)aWebView url:(NSURL*)aUrl
{
    self = [super init];
    if (self)
    {
        m_webView = aWebView;
        m_url = aUrl;
        KCRetain(m_url);
    }
    return self;
}


- (void)dealloc
{
    m_webView = nil;
    KCRelease(m_url);
    KCDealloc(super);
}

+ (KCWebImageSetterTask*)create:(KCWebView *)aWebView url:(NSURL*)aUrl
{
    KCWebImageSetterTask* task = [[KCWebImageSetterTask alloc] initWithWebView:aWebView url:aUrl];
    KCAutorelease(task);
    return task;
}


-(NSURL*)url
{
    return m_url;
}


@end

