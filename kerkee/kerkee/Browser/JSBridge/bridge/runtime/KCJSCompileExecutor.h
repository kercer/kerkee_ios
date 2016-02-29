//
//  KCJSCompileExecutor.h
//  kerkee
//
//  Created by zihong on 16/2/29.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBaseDefine.h"
#import "KCWebView.h"

@interface KCJSCompileExecutor : NSObject

+ (id)compileJS:(NSString *)aJS webview:(KCWebView*)aWebview;

@end
