//
//  KCJSCallback.m
//  kerkee
//
//  Created by zihong on 15/11/16.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCJSCallback.h"

@interface KCJSCallback ()
{
    NSString* m_callbackId;
}

@end

@implementation KCJSCallback

+ (id)create:(NSString*)aCallbackId
{
    return [[KCJSCallback alloc] initWithCallbackId:aCallbackId];
}

- (id)initWithCallbackId:(NSString*)aCallbackId
{
    if (self = [super init])
    {
        m_callbackId = aCallbackId;
    }
    return self;
}

- (NSString*)getCallbackId
{
    return m_callbackId;
}

- (void)callbackJS:(KCWebView*)aWebview
{
    [KCJSExecutor callbackJS:aWebview callbackId:m_callbackId];
}

- (void)callbackJS:(KCWebView*)aWebview jsonString:(NSString *)aJsonString
{
    [KCJSExecutor callbackJS:aWebview callbackId:m_callbackId jsonString:aJsonString];
}

- (NSString*)description
{
    return m_callbackId;
}

@end
