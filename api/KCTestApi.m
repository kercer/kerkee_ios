//
//  KCTestApi.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCTestApi.h"
#import "KCBaseDefine.h"
#import "KCJSBridge.h"


@implementation KCTestApi

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}

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


+(void)testInfo:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getArgValule:@"testInfo"];
    KCLog(@"%@", jsonInfo);
    
    [KCJSBridge callbackJS:aWebView callBackID:[args getArgValule:@"callbackId"] string:@"This is testInfo callball"];
    
    

}

@end
