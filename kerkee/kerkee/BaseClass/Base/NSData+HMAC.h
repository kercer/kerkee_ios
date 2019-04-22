//
//  NSData+HMAC.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSData (HMAC)

- (NSData *)md5HashWithKey:(NSData *)key;
- (NSData *)sha1HashWithKey:(NSData *)key;
- (NSData *)sha256HashWithKey:(NSData *)key;
- (NSData *)sha512HashWithKey:(NSData *)key;

@end
