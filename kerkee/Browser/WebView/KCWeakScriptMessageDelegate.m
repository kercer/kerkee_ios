//
//  KCWeakScriptMessageDelegate.m
//  kerkee
//
//  Created by zihong on 2016/11/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCWeakScriptMessageDelegate.h"

@interface KCWeakScriptMessageDelegate()
{
}

@end

@implementation KCWeakScriptMessageDelegate
@synthesize scriptDelegate = m_scriptDelegate;


- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)aScriptDelegate
{
    self = [super init];
    if (self)
    {
        m_scriptDelegate = aScriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}


@end
