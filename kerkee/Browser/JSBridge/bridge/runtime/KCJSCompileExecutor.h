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

NS_ASSUME_NONNULL_BEGIN

@interface KCJSCompileExecutor : NSObject

+ (void)compileJS:(NSString *)aJS inWebView:(KCWebView*)aWebview completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler;

@end

NS_ASSUME_NONNULL_END
