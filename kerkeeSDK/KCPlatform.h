//
//  KCPlatform.h
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kerkee.h"

@interface KCPlatform : NSObject

+ (void)getNetworkType:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)getDevice:(KCWebView *)aWebView argList:(KCArgList *)aArgList;

@end
