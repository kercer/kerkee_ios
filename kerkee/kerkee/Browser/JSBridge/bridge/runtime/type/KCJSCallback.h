//
//  KCJSCallback.h
//  kerkee
//
//  Created by zihong on 15/11/16.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCJSType.h"
#import "KCJSExecutor.h"

@interface KCJSCallback : KCJSType

+ (id)create:(NSString*)aCallbackId;

- (id)initWithCallbackId:(NSString*)aCallbackId;
- (NSString*)getCallbackId;

- (void)callbackJS:(KCWebView*)aWebview;
- (void)callbackJS:(KCWebView*)aWebview jsonString:(NSString *)aJsonString;

@end
