//
//  KCApiOverrideJSBridgeClient.m
//  kerkeeDemo
//
//  Created by zihong on 15/11/9.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCApiOverrideJSBridgeClient.h"
#import "KCBaseDefine.h"
#import "KCJSBridge.h"

@implementation KCApiOverrideJSBridgeClient

+(void)testJSBrige:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getArgValule:@"info"];
    KCLog(@"%@", jsonInfo);
}

+(void)commonApi:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getArgValule:@"info"];
    KCLog(@"%@", jsonInfo);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"OK!" forKey:@"info"];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    KCAutorelease(json);
    //返回
    
    [KCJSBridge callbackJS:aWebView callBackID:[args getArgValule:@"callbackId"] jsonString:json];
    
}

@end
