//
//  NSString+KCExtension.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "NSString+KCExtension.h"
#import "KCBaseDefine.h"
#import "KCUtilMd5.h"
#import "KCURIComponents.h"

#pragma mark -

@implementation NSString(KCExtension)

- (NSArray *)kc_allURLs
{
	NSMutableArray * array = [NSMutableArray array];
    
	NSInteger stringIndex = 0;
	while ( stringIndex < self.length )
	{
		NSRange searchRange = NSMakeRange(stringIndex, self.length - stringIndex);
		NSRange httpRange = [self rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:searchRange];
		NSRange httpsRange = [self rangeOfString:@"https://" options:NSCaseInsensitiveSearch range:searchRange];
        
		NSRange startRange;
		if ( httpRange.location == NSNotFound )
		{
			startRange = httpsRange;
		}
		else if ( httpsRange.location == NSNotFound )
		{
			startRange = httpRange;
		}
		else
		{
			startRange = (httpRange.location < httpsRange.location) ? httpRange : httpsRange;
		}
        
		if (startRange.location == NSNotFound)
		{
			break;
		}
		else
		{
			NSRange beforeRange = NSMakeRange( searchRange.location, startRange.location - searchRange.location );
			if ( beforeRange.length )
			{
				//				NSString * text = [string substringWithRange:beforeRange];
				//				[array addObject:text];
			}
            
			NSRange subSearchRange = NSMakeRange(startRange.location, self.length - startRange.location);
			NSRange endRange = [self rangeOfString:@" " options:NSCaseInsensitiveSearch range:subSearchRange];
			if ( endRange.location == NSNotFound)
			{
				NSString * url = [self substringWithRange:subSearchRange];
				[array addObject:url];
				break;
			}
			else
			{
				NSRange URLRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
				NSString * url = [self substringWithRange:URLRange];
				[array addObject:url];
                
				stringIndex = endRange.location;
			}
		}
	}
    
	return array;
}

- (NSString *)kc_queryStringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray * pairs = [NSMutableArray array];
	for ( NSString * key in [dict keyEnumerator] )
	{
		if ( !([[dict valueForKey:key] isKindOfClass:[NSString class]]) )
		{
			continue;
		}
        
		NSString * value = [dict objectForKey:key];
		NSString * urlEncoding = [value kc_URLEncoding];
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
	}
    
	return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)kc_urlByAppendingDict:(NSDictionary *)params
{
    NSString* paramsToken = (params != nil && params.count > 0) ? @"?" :@"";
    KCURIComponents *co = [KCURIComponents componentsWithString:self];
    NSString* fragment = [co fragment];
    NSURL * parsedURL = [NSURL URLWithString:self];
    NSString * queryPrefix = parsedURL.query ? @"&" : paramsToken;
    if ([fragment containsString:@"?"]) {
        queryPrefix = @"&";
    }
    NSString * query = [self kc_queryStringFromDictionary:params];
    return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)kc_queryStringFromArray:(NSArray *)array
{
	NSMutableArray *pairs = [NSMutableArray array];
    
	for ( NSUInteger i = 0; i < [array count]; i += 2 )
	{
		NSObject * obj1 = [array objectAtIndex:i];
		NSObject * obj2 = [array objectAtIndex:i + 1];
        
		NSString * key = nil;
		NSString * value = nil;
        
		if ( [obj1 isKindOfClass:[NSNumber class]] )
		{
			key = [(NSNumber *)obj1 stringValue];
		}
		else if ( [obj1 isKindOfClass:[NSString class]] )
		{
			key = (NSString *)obj1;
		}
		else
		{
			continue;
		}
        
		if ( [obj2 isKindOfClass:[NSNumber class]] )
		{
			value = [(NSNumber *)obj2 stringValue];
		}
		else if ( [obj1 isKindOfClass:[NSString class]] )
		{
			value = (NSString *)obj2;
		}
		else
		{
			continue;
		}
        
		NSString * urlEncoding = [value kc_URLEncoding];
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
	}
    
	return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)kc_urlByAppendingArray:(NSArray *)params
{
    NSURL * parsedURL = [NSURL URLWithString:self];
	NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString * query = [self kc_queryStringFromArray:params];
	return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)kc_urlByAppendingKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
	va_list args;
	va_start( args, first );
    
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
        
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
        
		[dict setObject:value forKey:key];
	}
    
	return [self kc_urlByAppendingDict:dict];
}

- (NSString *)kc_queryStringFromKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
	va_list args;
	va_start( args, first );
    
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
        
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
        
		[dict setObject:value forKey:key];
	}
    
	return [self kc_queryStringFromDictionary:dict];
}

- (BOOL)kc_empty
{
	return [self length] > 0 ? NO : YES;
}

- (BOOL)kc_notEmpty
{
	return [self length] > 0 ? YES : NO;
}

- (BOOL)kc_is:(NSString *)other
{
	return [self isEqualToString:other];
}

- (BOOL)kc_isValueOf:(NSArray *)array
{
	return [self kc_isValueOf:array caseInsens:NO];
}

- (BOOL)kc_isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens
{
	NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : 0;
    
	for ( NSObject * obj in array )
	{
		if ( NO == [obj isKindOfClass:[NSString class]] )
			continue;
        
		if ( [(NSString *)obj compare:self options:option] )
			return YES;
	}
    
	return NO;
}

- (NSString *)kc_URLEncoding
{
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                 (CFStringRef)self,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                 kCFStringEncodingUTF8));
    KCAutorelease(outputStr);
    return outputStr;
}

- (NSString *)kc_URLDecoding
{
	NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
							withString:@" "
							   options:NSLiteralSearch
								 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)kc_hashString
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[self hash]];
}

- (NSString *)kc_MD5
{
	NSData * value;
    
	value = [NSData dataWithBytes:[self UTF8String] length:[self length]];
    
    return [KCUtilMd5 MD5String:value];
}

- (NSString *)kc_hashMD5String
{
    NSString* strMD5 = [self kc_MD5];
    return [strMD5 kc_hashString];
}

@end
