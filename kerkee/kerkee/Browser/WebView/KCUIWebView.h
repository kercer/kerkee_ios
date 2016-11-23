//
//  KCWebView.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "KCWebViewProgressDelegate.h"

@class KCUIWebView;



@interface KCUIWebView : UIWebView


@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;

@property (nonatomic, assign) id<KCWebViewProgressDelegate> progressDelegate;


- (int)getWebViewID;


- (id)getAttach;
- (void)setAttach:(id)aAttch;

@end
