//
//  KCApiBridgeManager.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCApiBridgeManager.h"
#import "KCApiBridge.h"
#import "KCBaseDefine.h"
#import "KCJSExecutor.h"


@implementation KCApiBridgeManager

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
    NSString* jsonInfo = [args getObject:@"info"];
    NSLog(@"%@", jsonInfo);
}

+(void)commonApi:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getObject:@"info"];
    NSLog(@"%@", jsonInfo);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"OK!" forKey:@"info"];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    KCAutorelease(json);
    //返回

    [KCJSExecutor callbackJS:aWebView callbackId:[args getObject:@"callbackId"] jsonString:json];

}

@end
