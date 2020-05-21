//
//  KCUtilURI.m
//  kerkee
//
//  Created by zihong on 15/12/14.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCUtilURI.h"
#import "KCStack.h"
#import "KCString.h"

@implementation KCUtilURI

/**
 * TODO refactor this algorithm, it's a bit chunky and not so readable
 *
 * @param aPath
 * @return
 */
+ (NSString*) removeDotSegments:(NSString*)aPath
{
    KCStack* output = [[KCStack alloc] init];
    
    NSString* input = aPath;
    
    while (![input kc_isEmpty])
    {
        if ([input kc_startsWith:@"../"] || [input kc_startsWith:@"./"])
        {
            input = [input substringFromIndex:[input kc_indexOf:@"/"]+1];
        }
        else if ([input kc_startsWith:@"/.."])
        {
            input = [input kc_substring:3];
            if (![output isEmpty])
            {
                [output pop];
            }
        }
        else if ([input kc_equals:@"/."])
        {
            input = @"/";
        }
        else if ([input kc_startsWith:@"/."])
        {
            input = [input kc_substring:2];
        }
        else if ([input kc_equals:@"."] || [input kc_equals:@".."])
        {
            input = @"";
        }
        else
        {
            int segmentIndex = [input kc_indexOf:@"/" startIndex:1];
            if (segmentIndex == -1)
            {
                segmentIndex = (int)input.length;
            }
            
            NSString* pathSegment = [input kc_substring:0 end:segmentIndex];
            input = [input kc_substring:segmentIndex];
            if (![pathSegment kc_isEmpty])
            {
                [output push:pathSegment];
            }
        }
    }
    
    return [self join:output];
}

+ (NSString*)join:(KCStack*)aContainer
{
    return [self join:aContainer delimiter:@""];
}

/**
 * Joins a collection of strings to a single string, all parts are merged with a delimiter string.
 *
 * @param aContainer
 * @param aDelimiter
 * @return
 */
+ (NSString*)join:(KCStack*)aContainer delimiter:(NSString*)aDelimiter
{
    NSMutableString* builder = [[NSMutableString alloc] init];
    NSArray* stack = aContainer.stack;
    
    NSUInteger count = [aContainer size];
    for (int i = 0; i < count; ++i)
    {
        [builder appendString:[stack objectAtIndex:i]];
        if (i < count-1)
            [builder appendString:aDelimiter];
    }
    return builder;
}

@end
