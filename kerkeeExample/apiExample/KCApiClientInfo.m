//
//  KCClientInfoApi.m
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "KCApiClientInfo.h"

@implementation KCApiClientInfo

+ (void)getRequestParam:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:@"NTk0MTQ4MTE4OTU4NzQ2NDI2MQ" forKey:@"p1"];
    [dic setObject:@"-1" forKey:@"pid"];
    [dic setObject:@"Y29tLnNvaHUubmV3c3BhcGVy" forKey:@"token"];
    [dic setObject:@"02ffff110611118bce83f5a21bd814a1a7c22c2fd44308" forKey:@"gid"];
    [dic setObject:@"26" forKey:@"apiVersion"];
    [dic setObject:@"10" forKey:@"sid"];
    [dic setObject:@"1" forKey:@"u"];
    [dic setObject:@"Y29tLnNvaHUubmV3c3BhcGVy" forKey:@"bid"];
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *callbackId = [aArgList getObject:(@"callbackId")];
    if(nil == callbackId)
    return;
    [KCJSExecutor callbackJS:aWebView callbackId:callbackId jsonString:json];
}

+ (void)getHost:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    
}


@end
