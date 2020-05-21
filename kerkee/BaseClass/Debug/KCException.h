//
//  KCException.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define startSetUncaughtExceptionHandler [KCException startUncaughtExceptionHandler];

@interface KCException : NSObject

+(void)startUncaughtExceptionHandler;

@end
