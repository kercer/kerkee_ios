//
//  KCWidget.m
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCWidget.h"
#import "KCJSBridge.h"
#import "KCSDKJSDefine.h"
#import "KCBaseDefine.h"

//all this is example
@implementation KCWidget

+ (void)toast:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    if(nil == aArgList)
        return;
    NSString* message = [aArgList getString:@"info"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget toast" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    KCRelease(alert);
    [alert show];
}

+ (void)showDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    if(nil == aArgList)
        return;
    
    NSString* message = [aArgList getString:@"message"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget showDialog" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    KCRelease(alert);
    [alert show];
}
+ (void)alertDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *tostStr = [aArgList toString];
    if(nil == tostStr)
        return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget alertDialog" message:tostStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    KCRelease(alert);
}

@end
