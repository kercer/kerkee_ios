//
//  KCClientInfoApi.h
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kerkee.h"

@interface KCApiClientInfo : NSObject

+ (void)getRequestParam:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)getHost:(KCWebView *)aWebView argList:(KCArgList *)aArgList;

@end
