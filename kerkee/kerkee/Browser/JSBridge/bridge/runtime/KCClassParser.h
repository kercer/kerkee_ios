//
//  KCClassParser.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"

@interface KCClassParser : NSObject

+ (KCClassParser *)createParser:(NSDictionary *)dic;

- (NSString *)getJSClzName;
- (NSString *)getJSMethodName;
- (KCArgList *)getArgList;

@end
