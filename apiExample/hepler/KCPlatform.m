//
//  KCPlatform.m
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCPlatform.h"
#include "Reachability.h"
#import "KCSDKJSDefine.h"
#import "UIDevice+KCHardware.h"

@implementation KCPlatform

#define kProfileClientIDKey					(@"client id")
#define kDefaultDeviceAdaptID               (@"0")
#define kDefaultProfileClientID             (@"0")
#define kDeviceAdaptIDKey					(@"device adapt id")//即sid, 服务器用来适配图片 9:iphone3 10:iphone4及以上(retina) 21:ipad
#define kBundleVersionKey					(@"CFBundleShortVersionString")
#define kBundleBuild                        (@"CFBundleVersion")
#define kDeviceModel						(@"iPhone")


//渠道号
+ (int)marketID
{
    NSError *marketIdFileError = nil;
    NSString *marketIdFilePath	= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"market.id"];
    NSString *marketIdStr = [NSString stringWithContentsOfFile:marketIdFilePath encoding:NSUTF8StringEncoding error:&marketIdFileError];
    
    int marketId = [marketIdStr intValue];
    
    return marketId;
}



+ (void)getDevice:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *callbackId = [aArgList getObject:kKerkeeSDK_CallbackId];
    if(nil == callbackId)
        return;
    
    //device info
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if ([uid length] == 0) {
        uid = kDefaultProfileClientID;
    }
    
    // get device adapt id
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceAdaptIDKey];
    if ([sid length] == 0) {
        sid = kDefaultDeviceAdaptID;
    }
    
    //get udid
#if TARGET_IPHONE_SIMULATOR
    NSString *UDID = @"64E5B68E-8EA1-4CB8-8544-C04FEA1AED3E";
#else
    NSString *UDID = [UIDevice deviceUDID];
#endif
    
    //get version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    if(nil == version || [version length] <= 0){
        version = @"";
    }

    //get system name and version
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];

#if TARGET_IPHONE_SIMULATOR
    NSString *deviceInfo = kDeviceModel;
#else
    NSString *deviceInfo = [[UIDevice currentDevice] model];
#endif
    
    //wifi or 3G or gprs
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    int marketId = [KCPlatform marketID];
    
    //5.1 add build
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    if (nil == appBuild || [appBuild length] <= 0) {
        appBuild = @"";
        //unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&buildCode=%@", appBuild];
    }
    
    /*
    jsonObject.put("model", Build.MODEL);
    jsonObject.put("brand", Build.BRAND);
    jsonObject.put("device", Build.DEVICE);
    jsonObject.put("display", screenWidth + "X" + screenHeight);
    jsonObject.put("product", Build.PRODUCT);
    jsonObject.put("hardware", Build.HARDWARE);
    */
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:uid forKey:@"uid"];
    [dic setValue:sid forKey:@"sid"];
    [dic setValue:UDID forKey:@"UDID"];
    [dic setValue:version forKey:@"version"];
    [dic setValue:systemName forKey:@"systemName"];
    [dic setValue:systemVersion forKey:@"systemVersion"];
    [dic setValue:deviceInfo forKey:@"deviceInfo"];
    [dic setValue:[NSNumber numberWithInt:marketId] forKey:@"marketId"];
    switch (status) {
        case ReachableViaWWAN:
            [dic setValue:@"WWAN" forKey:@"networkstatus"];
            break;
        case ReachableViaWiFi:
            [dic setValue:@"WiFi" forKey:@"networkstatus"];
            break;
        default:
            break;
    }
    [dic setValue:appBuild forKey:@"appBuild"];
    
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    if(nil != json){
        [KCJSBridge callbackJS:aWebView callBackID:callbackId jsonString:json];
    }
}

+ (void)getNetworkType:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *callbackId = [aArgList getObject:kKerkeeSDK_CallbackId];
    if(nil == callbackId)
        return;
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    NSString *netType = nil;
    
    switch (status) {
        case ReachableViaWWAN:
            netType = @"WWAN";
            break;
        case ReachableViaWiFi:
            netType = @"WiFi";
            break;
        default:
            break;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:netType forKey:@"network"];
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    if(nil != json){
        [KCJSBridge callbackJS:aWebView callBackID:callbackId jsonString:json];
    }
}

+ (BOOL)isFastMobileNetwork
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
}

@end
