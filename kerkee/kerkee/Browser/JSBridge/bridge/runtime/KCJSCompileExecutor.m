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

+ (id)compileJS:(NSString *)aJS webview:(KCWebView*)aWebview
{
    if (!aJS) return nil;
    
    NSString *js = [[NSString alloc] initWithFormat:@"JSON.stringify(%@)", aJS];
    NSString* result = [KCJSExecutor callJS:js WebView:aWebview]
    KCAutorelease(js);
    
    id resultObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    return resultObj;
}

@end
