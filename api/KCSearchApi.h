//
//  KCSearchApi.h
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kerkee.h"

@interface KCSearchApi : NSObject

+ (void)searchHotWord:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)addSubscribe:(KCWebView *)aWebView argList:(KCArgList *)aArgList;
+ (void)updateSearchWord:(KCWebView *)aWebView argList:(KCArgList *)aArgList;

@end
