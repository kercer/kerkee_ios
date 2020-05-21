//
//  KCUtilURL.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface KCUtilURL : NSObject

+(NSDictionary*) getQuery:(NSURL*)aUrl;
+(NSDictionary*) dictionaryFromQuery:(NSString*)aQuery usingEncoding:(NSStringEncoding)aEncoding;
+(NSString*) getValueForKey:(NSString*)aKey URL:(NSURL*)aUrl;

+(NSURL*) removeParamWithKey:(NSString*)aKey URL:(NSURL*)aUrl;

+(BOOL) isImageUrl:(NSURL*)aUrl;
+(BOOL) isItmsUrl:(NSURL*)aUrl;
+(BOOL) isItunesUrl:(NSURL*)aUrl;


@end
