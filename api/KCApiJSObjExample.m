//
//  KCApiJSObjExample.m
//  kerkeeDemo
//
//  Created by zihong on 2015-11-10.
//  Copyright © 2015 zihong. All rights reserved.
//

#import "KCApiJSObjExample.h"
#import "KCJSObjDefine.h"

@implementation KCApiJSObjExample

- (NSString*)getJSObjectName
{
    return kJS_JSObjExampleModule;
}


-(void)objExampleNotStaticFunction:(KCWebView*)aWebView argList:(KCArgList*)args
{
    KCLog(@"objExampleNotStaticFunction");
}

+(void)objExampleStaticFunction:(KCWebView*)aWebView argList:(KCArgList*)args
{
    KCLog(@"objExampleStaticFunction");
}

@end
