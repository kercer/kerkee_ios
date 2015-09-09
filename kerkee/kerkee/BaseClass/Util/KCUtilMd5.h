//
//  KCUtilMd5.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface KCUtilMd5 : NSObject

+ (NSString*)fileMD5:(NSString*)path;
+ (NSData *)MD5:(NSData*)data;
+ (NSString *)MD5String:(NSData*)data;

@end
