//
//  KCClientUI.m
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "KCClientUI.h"

@implementation KCClientUI

+ (void)clientToast:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    if(nil == aArgList)
        return;
    NSString* message = [aArgList getString:@"msg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCClientUI clientToast" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    KCRelease(alert);
    [alert show];
}

@end
