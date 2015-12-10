//
//  KCUtilGzip.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCBaseDefine.h"

@interface KCUtilGzip : NSObject

+ (NSData *)gzipData:(NSData *)pUncompressedData;
+ (NSData *)uncompressZippedData:(NSData *)compressedData;
@end

// Gzip functionality - compression level in range 0 - 1 (-1 for default)
KC_EXTERN NSData *gzipData(NSData *data, float level);
KC_EXTERN BOOL isGzippedData(NSData *data);