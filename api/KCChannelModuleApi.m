//
//  KCChannelModuleApi.m
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCChannelModuleApi.h"

@implementation KCChannelModuleApi

+ (void)getChannelInfo:(KCWebView*)aWebView argList:(KCArgList*)args
{
    NSString* jsonInfo = [args getArgValule:@"info"];
    NSLog(@"%@", jsonInfo);
    
    //NSString *string = @"http://api.k.sohu.com/api/channel/v5/news.go?channelId=247&num=20&page=1&picScale=11&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json&from=channel&pull=1&focusPosition=2&cursor=0&cdma_lng=116.332478&cdma_lat=39.997120&net=wifi&p1=NTk0MTQ4MTE4OTU4NzQ2NDI2MQ==&pid=-1&apiVersion=26&sid=10&u=1&bid=Y29tLnNvaHUubmV3c3BhcGVy";
    
    NSString *string = @"http://api.k.sohu.com/api/channel/v5/news.go?channelId=247&num=20&imgTag=1&showPic=1&picScale=11&rt=json&net=wifi&cdma_lat=39.997120&cdma_lng=116.332478&from=channel&page=1&action=0&mode=0&cursor=0&mainFocalId=0&focusPosition=2&viceFocalId=0&lastUpdateTime=0&p1=NTk0MTQ4MTE4OTU4NzQ2NDI2MQ&gid=02ffff110611118bce83f5a21bd814a1a7c22c2fd44308&pid=-1&_=1429685956559";
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:string forKey:@"url"];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    //返回
    
    NSString *callbackId = [args getArgValule:(@"callbackId")];
    if(nil == callbackId)
        return;
    [KCJSBridge callbackJS:aWebView callBackID:callbackId jsonString:json];
}

@end
