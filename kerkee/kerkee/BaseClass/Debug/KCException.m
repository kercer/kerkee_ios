//
//  KCException.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCException.h"
#import "UIDevice+KCHardware.h"
#import "KCUtilFile.h"
#import "KCLog.h"

#define CRASH_PATH @"crash.log"

@implementation KCException


+(NSString*)getCrashLogPath
{
    return [KCUtilFile dataPath:CRASH_PATH];
}

+(NSString*)getDeviceInfo
{
    NSString* info = [NSString stringWithFormat:@"hardware=%@, osVersion=%@", [[UIDevice currentDevice] hardwareDescription],  [UIDevice currentDevice].systemVersion];
    
    return info;
}

+(void)startUncaughtExceptionHandler
{
    NSSetUncaughtExceptionHandler (&uncaughtExceptionHandler);
}


void uncaughtExceptionHandler(NSException *exception)
{
    NSString* strDevice = [KCException getDeviceInfo];
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    KCLog(@"%@", exception);
    
    NSString *str = [NSString stringWithFormat:@"\n**************CrashInfo Begin**************\nDeviceInfo:\n%@\nExceptionName:\n%@\nReason:\n%@\nCllStack:\n%@\n**************CrashInfo End**************\n",strDevice,
                     name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString* path = [KCException getCrashLogPath];
    KCLog(@"%@\n%@", path, str);
    [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


@end
