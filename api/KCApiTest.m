//
//  KCTestApi.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCApiTest.h"
#import "KCBaseDefine.h"
#import "KCJSBridge.h"


@implementation KCApiTest


+(void)testInfo:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getArgValule:@"testInfo"];
    KCLog(@"%@", jsonInfo);
    
    [KCJSBridge callbackJS:aWebView callBackID:[args getArgValule:@"callbackId"] string:@"This is testInfo callball"];
    
    

}

@end
