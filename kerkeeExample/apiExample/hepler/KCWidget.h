//
//  KCWidget.h
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kerkee.h"

//widget
@interface KCWidget : NSObject

+ (void)toast:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)commonApi:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)onSetImage:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)showDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)alertDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList;

@end
