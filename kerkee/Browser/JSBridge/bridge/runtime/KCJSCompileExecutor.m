//
//  KCJSCompileExecutor.m
//  kerkee
//
//  Created by zihong on 16/2/29.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCJSCompileExecutor.h"
#import "KCJSExecutor.h"

@implementation KCJSCompileExecutor

+ (void)compileJS:(NSString *)aJS inWebView:(KCWebView*)aWebview completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))aCompletionHandler
{
    if (!aJS)
    {
        NSError* err = [[NSError alloc] initWithDomain:@"JS not NULL" code:-1 userInfo:nil];
        aCompletionHandler(nil, err);
        return ;
    }
    
    NSString *js = [[NSString alloc] initWithFormat:@"JSON.stringify(%@)", aJS];
    [KCJSExecutor callJS:js inWebView:aWebview completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        id resultObj = nil;
        if (result != nil)
        {
            resultObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        }
        aCompletionHandler(resultObj, nil);

    }]
    KCAutorelease(js);
    
}

@end
