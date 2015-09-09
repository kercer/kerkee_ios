//
//  KCUtilCoding.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>


@interface KCUtilCoding : NSObject

+ (NSString *) encodeToPercentEscapeString: (NSString *) input;
//encoding use CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
+ (NSString *)encodeToPercentEscapeString: (NSString *)input encoding:(CFStringEncoding)encoding;
+ (NSString *) decodeFromPercentEscapeString: (NSString *) input;

+ (NSString*) encodeUseBase64:(NSData *)data;
+ (NSData*) decodeUseBase64:(NSString *)string;

#pragma mark - conver
+(NSString *) parseByteArrayToHexString:(NSData *) data;
+(NSData*) parseHexToByteArray:(NSString*) hexString;

#pragma mark DES
//des code from http://www.cnblogs.com/janken/archive/2012/04/05/2432930.html

typedef NSString*(^blockEncode)(NSData*);
typedef NSData* (^blockDecode)(NSString*);

//the iv default { 0, 0, 0, 0, 0, 0, 0, 0 }, and use hex to encrypt
+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey;
//if iv is null, the iv default { 0, 0, 0, 0, 0, 0, 0, 0 }, and use hex to encrypt
+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey iv:(Byte*)aIV;
+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey iv:(Byte*)aIV encodeBlock:(blockEncode)aBlockEncode;
//the iv default { 0, 0, 0, 0, 0, 0, 0, 0 }, and use hex to decrypt
+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey;
//if iv is null, the iv default { 0, 0, 0, 0, 0, 0, 0, 0 }, and use hex to decrypt
+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey iv:(Byte*)aIV;
+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey iv:(Byte*)aIV decodeBlock:(blockDecode)aBlockDecode;


@end
