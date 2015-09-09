//
//  KCClientInfoApi.m
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "KCClientInfoApi.h"

@implementation KCClientInfoApi

+ (void)getRequestParam:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //http://api.k.sohu.com/api/channel/v5/news.go?channelId=247&num=20&page=1&picScale=11&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json&from=channel&pull=1&focusPosition=2&cursor=0&cdma_lng=116.332478&cdma_lat=39.997120&net=wifi&p1=NTk0MTQ4MTE4OTU4NzQ2NDI2MQ==&pid=-1&apiVersion=26&sid=10&u=1&bid=Y29tLnNvaHUubmV3c3BhcGVy
    
    //http://onlinetestapi.k.sohu.com/api/channel/v5/news.go?channelId=50&num=20&imgTag=1&showPic=1&picScale=11&rt=json&net=wifi&cdma_lat=39.996938&cdma_lng=116.333129&from=channel&page=1&action=0&mode=0&cursor=0&mainFocalId=0&focusPosition=1&viceFocalId=0&lastUpdateTime=0&p1=NTk0NDgzNjMxMTY2MzE2MTQ0Nw%253D%253D&gid=02ffff110611118bce83f5a21bd814a1a7c22c2fd44308&pid=&_=1429680245477
    
    
    [dic setObject:@"NTk0MTQ4MTE4OTU4NzQ2NDI2MQ" forKey:@"p1"];
    [dic setObject:@"-1" forKey:@"pid"];
    [dic setObject:@"Y29tLnNvaHUubmV3c3BhcGVy" forKey:@"token"];
    [dic setObject:@"02ffff110611118bce83f5a21bd814a1a7c22c2fd44308" forKey:@"gid"];
    [dic setObject:@"26" forKey:@"apiVersion"];
    [dic setObject:@"10" forKey:@"sid"];
    [dic setObject:@"1" forKey:@"u"];
    [dic setObject:@"Y29tLnNvaHUubmV3c3BhcGVy" forKey:@"bid"];
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *callbackId = [aArgList getArgValule:(@"callbackId")];
    if(nil == callbackId)
    return;
    [KCJSBridge callbackJS:aWebView callBackID:callbackId jsonString:json];
}

+ (void)getHost:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    
}


@end
