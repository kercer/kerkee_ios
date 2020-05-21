//
//  KCUtilWebView.m
//  kerkee
//
//  Created by zihong on 2017/11/6.
//  Copyright © 2017年 zihong. All rights reserved.
//

#import "KCUtilWebView.h"
#import <objc/message.h>
#import <WebKit/WebKit.h>
#import "KCWebView.h"



@class WKWebView;

@implementation KCUtilWebView

+ (void)setWebViewUserAgent:(NSString*)aUserAgent webView:(KCWebView*)aWebView
{
    if (aUserAgent == NULL || aUserAgent.length == 0) return;
    if(aWebView.isUsingUIWebView)
    {
        [aWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *_Nullable oldAgent, NSError * _Nullable error) {
            NSString *user_agent;// = [NSString stringWithFormat:@"%@ %@",oldAgent,self.userAgent];
            
            if([oldAgent containsString:aUserAgent])
            {
                oldAgent = [oldAgent substringToIndex:oldAgent.length - aUserAgent.length];
                user_agent = [NSString stringWithFormat:@"%@%@",oldAgent, aUserAgent];
            }
            else
            {
                user_agent=[NSString stringWithFormat:@"%@ %@",oldAgent,aUserAgent];
            }
            id webDocumentView;
            id webView;
            
            // suppress the warnings
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            webDocumentView = ((id(*)(id, SEL))objc_msgSend)(aWebView.realWebView, @selector(_documentView));
            #pragma clang diagnostic pop
            
            object_getInstanceVariable(webDocumentView, "_webView", (void**)&webView);
            NSString *selString = [@"setCustom" stringByAppendingString:@"UserAgent:"];
            SEL sel = NSSelectorFromString(selString);
            [webView performSelector:sel withObject:user_agent];
        }];
    }
    else
    {
        [aWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *_Nullable oldAgent, NSError * _Nullable error) {
            
            NSString *user_agent;//=[NSString stringWithFormat:@"%@ %@",oldAgent,self.userAgent];
            
            if([oldAgent containsString:aUserAgent])
            {
                oldAgent = [oldAgent substringToIndex:oldAgent.length - aUserAgent.length];
                user_agent = [NSString stringWithFormat:@"%@%@", oldAgent, aUserAgent];
                
            }
            else
            {
                user_agent = [NSString stringWithFormat:@"%@ %@",oldAgent, aUserAgent];
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:user_agent, @"UserAgent", nil];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ((WKWebView *)aWebView.realWebView).customUserAgent = user_agent;
            
        }];
    }
}

@end
