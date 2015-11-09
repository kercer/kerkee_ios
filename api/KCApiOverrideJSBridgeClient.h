//
//  KCApiOverrideJSBridgeClient.h
//  kerkeeDemo
//
//  Created by zihong on 15/11/9.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCWebView.h"
#import "KCArgList.h"

@interface KCApiOverrideJSBridgeClient : NSObject

+(void)testJSBrige:(KCWebView*)aWebView argList:(KCArgList*)args;
+(void)commonApi:(KCWebView*)aWebView argList:(KCArgList*)args;

@end
