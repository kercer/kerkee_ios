//
//  NSData+HMAC.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSData+HMAC.h"

#if TARGET_OS_MAC && (TARGET_OS_IPHONE || MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)

#define COMMON_DIGEST_FOR_OPENSSL
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define HMAC_MD5(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgMD5, key, keylen, data, datalen, md)
#define HMAC_SHA1(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA1, key, keylen, data, datalen, md)
#define HMAC_SHA256(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA256, key, keylen, data, datalen, md)
#define HMAC_SHA512(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA512, key, keylen, data, datalen, md)

@implementation NSData (HMAC)

- (NSData *)md5HashWithKey:(NSData *)key
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    HMAC_MD5([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha1HashWithKey:(NSData *)key
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    HMAC_SHA1([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:CC_SHA1_DIGEST_LENGTH];
}

- (NSData *)sha256HashWithKey:(NSData *)key
{
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    
    HMAC_SHA256([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)sha512HashWithKey:(NSData *)key
{
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    
    HMAC_SHA512([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:CC_SHA512_DIGEST_LENGTH];
}

@end

#endif
