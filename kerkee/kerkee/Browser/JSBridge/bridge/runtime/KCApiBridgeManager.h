//
//  KCApiBridgeManager.h
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCClass.h"
#import "KCWebView.h"
#import "KCArgList.h"

@interface KCApiBridgeManager : NSObject


+(void)testJSBrige:(KCWebView*)aWebView argList:(KCArgList*)args;
+(void)commonApi:(KCWebView*)aWebView argList:(KCArgList*)args;

@end
