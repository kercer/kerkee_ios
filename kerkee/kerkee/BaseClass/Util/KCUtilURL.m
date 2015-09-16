//
//  KCUtilURL.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilURL.h"
#import "KCBaseDefine.h"
#import "NSString+KCExtension.h"

@implementation KCUtilURL

+(NSDictionary*)getQuery:(NSURL*)aUrl
{
    NSString* strQuery = aUrl.query;
//    NSArray* arrKeyValue = [strQuery componentsSeparatedByString:@"&"];
//    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
//    KCAutorelease(dic);
//    for (NSString* strKeyValue in arrKeyValue)
//    {
//        NSArray* arrKeyValue = [strKeyValue componentsSeparatedByString:@"="];
//        NSString* key = @"";
//        NSString* value = @"";
//        for (int i = 0; i<arrKeyValue.count; ++i)
//        {
//            if (i == 0)
//            {
//                key = [arrKeyValue objectAtIndex:i];
//                key = [key stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//            }
//            else if(i == 1)
//            {
//                value  = [arrKeyValue objectAtIndex:i];
//            }
//        }
//        
//        if (key.length>0)
//        {
//            [dic setObject:value forKey:key];
//        }
//    }
//    return dic;
    

    NSDictionary* dic = [KCUtilURL dictionaryFromQuery:strQuery usingEncoding:NSUTF8StringEncoding];
    return dic;
}


+ (NSDictionary*)dictionaryFromQuery:(NSString*)aQuery usingEncoding:(NSStringEncoding)aEncoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:aQuery];
    KCAutorelease(scanner);
    while (![scanner isAtEnd])
    {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2)
        {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:aEncoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:aEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}


+(NSString*)getValueForKey:(NSString*)aKey URL:(NSURL*)aUrl
{
    if(!aKey) return nil;
    NSDictionary* dic = [self getQuery:aUrl];
    return [dic objectForKey:aKey];
}

+(NSURL*)removeParamWithKey:(NSString*)aKey URL:(NSURL*)aUrl
{
    if(!aKey || aKey.length==0) return aUrl;
    NSString* strUrl = aUrl.absoluteString;
    NSArray* arr = [strUrl componentsSeparatedByString:@"?"];
    NSString* base = [arr objectAtIndex:0];
    if(base)
    {
        NSMutableDictionary* dicParams = [[self getQuery:aUrl] mutableCopy];
        [dicParams removeObjectForKey:aKey];
        NSString* newUrlStr = [base urlByAppendingDict:dicParams];
        return [NSURL URLWithString:newUrlStr];
    }
    return aUrl;
}

+(BOOL)isImageUrl:(NSURL*)aUrl
{
    BOOL isImage = NO;
    if (!aUrl) return isImage;
    NSString* lastPath = aUrl.lastPathComponent;
    NSString *fileExtension = [[lastPath pathExtension] lowercaseString];
//    DLog(@"%@, %d",fileExtension, fileExtension.length);
    if (fileExtension)
    {
        if ([fileExtension isEqualToString:@"gif"]
            || [fileExtension isEqualToString:@"jpeg"]
            || [fileExtension isEqualToString:@"jpg"]
            || [fileExtension isEqualToString:@"png"])
        {
            isImage = YES;
        }
        
    }
    
    return isImage;
}

+(BOOL) isItmsUrl:(NSURL*)aUrl
{
    BOOL isItms = NO;
    if(!aUrl) return isItms;
    if ([aUrl.scheme isEqualToString:@"itms"] || [aUrl.scheme isEqualToString:@"itms-apps"] || [aUrl.scheme isEqualToString:@"itmss"])
    {
        isItms = YES;
    }
    return isItms;
}

+(BOOL) isItunesUrl:(NSURL*)aUrl
{
    NSRange rangDetails = [aUrl.host rangeOfString:@"itunes.apple.com"];
    
    KCLog(@"%@", aUrl.host);
    
    if(rangDetails.length > 0)
        return YES;
    else
        return NO;
}




@end
