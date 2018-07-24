//
//  KCURIComponents.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCURIQuery.h"
#import "KCBaseDefine.h"


@interface KCURIQuery ()
@property(atomic, readwrite, copy) NSString* percentEncodedString;
@end


@implementation KCURIQuery

#pragma mark Convenience

+ (NSDictionary *)parametersFromURL:(NSURL *)aUrl options:(KCURIQueryParameterDecodingOptions)aOptions;
{
    return [[self queryWithURL:aUrl] parametersWithOptions:aOptions];
}

+ (NSDictionary *)parametersFromURL:(NSURL *)aUrl
{
    return [self parametersFromURL:aUrl options:KCURIQueryParameterDecodingPlusAsSpace];
}

+ (NSDictionary *)decodeString:(NSString *)aPercentEncodedQuery options:(KCURIQueryParameterDecodingOptions)aOptions;
{
    KCURIQuery *query = [[self alloc] initWithPercentEncodedString:aPercentEncodedQuery];
    NSDictionary *result = [query parametersWithOptions:aOptions];
    KCRelease(query);
    
    return result;
}

+ (NSString *)encodeParameters:(NSDictionary *)aParameters;
{
    KCURIQuery *query = [[KCURIQuery alloc] init];
    [query setParameters:aParameters];
    NSString *result = query.percentEncodedString;
    KCRelease(query);
    return result;
}

#pragma mark

+ (instancetype)queryWithURL:(NSURL *)aUrl;
{
    // Always resolve, since unlike paths there's no way for two queries to be in some way concatenated
    CFURLRef leakCFURL = (__bridge_retained CFURLRef)aUrl;
    CFURLRef cfURL = CFURLCopyAbsoluteURL(leakCFURL);
    
    NSString *string = (NSString *)CFBridgingRelease(CFURLCopyQueryString(cfURL,
                                                        NULL));  // leave unescaped
    
    KCURIQuery *result = [[self alloc] initWithPercentEncodedString:string];
    KCRelease(string);
    CFRelease(cfURL);
    CFRelease(leakCFURL);
    KCAutorelease(result);
    return result;
}

-(id)initWithPercentEncodedString:(NSString *)aString;
{
    if (self = [self init])
    {
        m_percentEncodedString = [aString copy];
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_percentEncodedString);
    KCDealloc(super);
}

@synthesize percentEncodedString = m_percentEncodedString;

- (NSDictionary *)parametersWithOptions:(KCURIQueryParameterDecodingOptions)aOptions;
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [self enumerateParametersWithOptions:aOptions usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        
        // Bail if doesn't fit dictionary paradigm
        if (!value || [result objectForKey:key])
        {
            *stop = YES;
            result = nil;
            return;
        }
        
        [result setObject:value forKey:key];
    }];
    
    return result;
}

- (void)enumerateParametersWithOptions:(KCURIQueryParameterDecodingOptions)aOptions usingBlock:(void (^)(NSString *, NSString *, BOOL *))aBlock;
{
    BOOL stop = NO;
    
    NSString *query = self.percentEncodedString; // we'll do our own decoding after separating components
    NSRange searchRange = NSMakeRange(0, query.length);
    
    while (!stop)
    {
        NSRange keySeparatorRange = [query rangeOfString:@"=" options:NSLiteralSearch range:searchRange];
        if (keySeparatorRange.location == NSNotFound) keySeparatorRange = NSMakeRange(NSMaxRange(searchRange), 0);
        
        NSRange keyRange = NSMakeRange(searchRange.location, keySeparatorRange.location - searchRange.location);
        NSString *key = [query substringWithRange:keyRange];
        
        NSString *value = nil;
        if (keySeparatorRange.length)   // there might be no value, so report as nil
        {
            searchRange = NSMakeRange(NSMaxRange(keySeparatorRange), query.length - NSMaxRange(keySeparatorRange));
            
            NSRange valueSeparatorRange = [query rangeOfString:@"&" options:NSLiteralSearch range:searchRange];
            if (valueSeparatorRange.location == NSNotFound)
            {
                valueSeparatorRange.location = NSMaxRange(searchRange);
                stop = YES;
            }
            
            NSRange valueRange = NSMakeRange(searchRange.location, valueSeparatorRange.location - searchRange.location);
            value = [query substringWithRange:valueRange];
            
            searchRange = NSMakeRange(NSMaxRange(valueSeparatorRange), query.length - NSMaxRange(valueSeparatorRange));
        }
        else
        {
            stop = YES;
        }
        
        if (aOptions & KCURIQueryParameterDecodingPlusAsSpace)
        {
            key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        }
        
        aBlock([key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              &stop);
    }
}

- (void)setParameters:(NSDictionary *)aParameters;
{
    if (!aParameters)
    {
        self.percentEncodedString = nil;
        return;
    }
    
    if (!aParameters.count)
    {
        self.percentEncodedString = @"";
        return;
    }
    
    // Build the list of parameters as a string
    for (NSString *aKey in [aParameters.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        [self addParameter:aKey value:[aParameters objectForKey:aKey]];
    }
}

- (void)addParameter:(NSString *)aKey value:(id <NSObject>)aValue;
{
    CFStringRef escapedKey = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aKey, NULL, CFSTR("+=&#"), kCFStringEncodingUTF8);
    // Escape + for safety as some backends interpret it as a space
    // = indicates the start of value, so must be escaped
    // & indicates the start of next parameter, so must be escaped
    // # indicates the start of fragment, so must be escaped
    
    CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aValue.description, NULL, CFSTR("+&#"), kCFStringEncodingUTF8);
    // Escape + for safety as some backends interpret it as a space
    // = is allowed in values, as there's no further value to indicate
    // & indicates the start of next parameter, so must be escaped
    // # indicates the start of fragment, so must be escaped
    
    // Append the parameter and its value to the full query string
    NSString *query = self.percentEncodedString;
    if (query)
    {
        query = [query stringByAppendingFormat:@"&%@=%@", escapedKey, escapedValue];
    }
    else
    {
        query = [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
    }
    
    self.percentEncodedString = query;
    
    CFRelease(escapedKey);
    CFRelease(escapedValue);
}

@end
