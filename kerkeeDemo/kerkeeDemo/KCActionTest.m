//
//  KCActionTest.m
//  kerkeeDemo
//
//  Created by zihong on 15/9/16.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCActionTest.h"
#import "KCBaseDefine.h"

@implementation KCActionTest


/**
 * Determine whether to perform custom operations protocol,if accept return true,else return false.
 */
-(BOOL) accept:(NSString*)aHost path:(NSString*)aPath
{
    if ([aHost isEqual:@"search"])
    {
        return true;
    }
    else
    {
        return false;
    }
}

/**
 * if accept function return true,invokeAction can be called,you call do something here
 */
-(void) invokeAction:(NSDictionary*)aParams
{
    KCLog(@"invokeAction");
}

@end
