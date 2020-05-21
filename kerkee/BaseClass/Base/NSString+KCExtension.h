//
//  NSString+KCExtension.h
//  
//
//  NSString+KCExtension.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>


#pragma mark -

@interface NSString(KCExtension)

- (NSArray *)kc_allURLs;

- (NSString *)kc_urlByAppendingDict:(NSDictionary *)params;
- (NSString *)kc_urlByAppendingArray:(NSArray *)params;
- (NSString *)kc_urlByAppendingKeyValues:(id)first, ...;

- (NSString *)kc_queryStringFromDictionary:(NSDictionary *)dict;
- (NSString *)kc_queryStringFromArray:(NSArray *)array;
- (NSString *)kc_queryStringFromKeyValues:(id)first, ...;

- (NSString *)kc_URLEncoding;
- (NSString *)kc_URLDecoding;

- (NSString *)kc_hashString;
- (NSString *)kc_hashMD5String;

- (NSString *)kc_MD5;

- (BOOL)kc_empty;
- (BOOL)kc_notEmpty;

- (BOOL)kc_is:(NSString *)other;

- (BOOL)kc_isValueOf:(NSArray *)array;
- (BOOL)kc_isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

@end
