//
//  KCUtilJson.m
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCUtilJson.h"
#import "KCAssert.h"

#import <mach/mach_time.h>
#import <objc/message.h>


//@implementation KCUtilJson

NSError *KCErrorWithMessage(NSString *message)
{
    NSDictionary<NSString *, id> *errorInfo = @{NSLocalizedDescriptionKey: message};
    return [[NSError alloc] initWithDomain:KCErrorDomain code:0 userInfo:errorInfo];
}

NSString *KCJSONStringify(id aJsonObject, NSError **error)
{
    static SEL JSONKitSelector = NULL;
    static NSSet<Class> *collectionTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selector = NSSelectorFromString(@"JSONStringWithOptions:error:");
        if ([NSDictionary instancesRespondToSelector:selector]) {
            JSONKitSelector = selector;
            collectionTypes = [NSSet setWithObjects:
                               [NSArray class], [NSMutableArray class],
                               [NSDictionary class], [NSMutableDictionary class], nil];
        }
    });
    
    // Use JSONKit if available and object is not a fragment
    if (JSONKitSelector && [collectionTypes containsObject:[aJsonObject classForCoder]]) {
        return ((NSString *(*)(id, SEL, int, NSError **))objc_msgSend)(aJsonObject, JSONKitSelector, 0, error);
    }
    
    // Use Foundation JSON method
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:aJsonObject
                        options:(NSJSONWritingOptions)NSJSONReadingAllowFragments
                        error:error];
    return jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : nil;
}

static id _KCJSONParse(NSString *aJsonString, BOOL mutable, NSError **error)
{
    static SEL JSONKitSelector = NULL;
    static SEL JSONKitMutableSelector = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selector = NSSelectorFromString(@"objectFromJSONStringWithParseOptions:error:");
        if ([NSString instancesRespondToSelector:selector]) {
            JSONKitSelector = selector;
            JSONKitMutableSelector = NSSelectorFromString(@"mutableObjectFromJSONStringWithParseOptions:error:");
        }
    });
    
    if (aJsonString) {
        
        // Use JSONKit if available and string is not a fragment
        if (JSONKitSelector) {
            NSInteger length = aJsonString.length;
            for (NSInteger i = 0; i < length; i++) {
                unichar c = [aJsonString characterAtIndex:i];
                if (strchr("{[", c)) {
                    static const int options = (1 << 2); // loose unicode
                    SEL selector = mutable ? JSONKitMutableSelector : JSONKitSelector;
                    return ((id (*)(id, SEL, int, NSError **))objc_msgSend)(aJsonString, selector, options, error);
                }
                if (!strchr(" \r\n\t", c)) {
                    break;
                }
            }
        }
        
        // Use Foundation JSON method
        NSData *jsonData = [aJsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (!jsonData) {
            jsonData = [aJsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            if (jsonData) {
                KCLog(@"KCJSONParse received the following string, which could "
                      "not be losslessly converted to UTF8 data: '%@'", aJsonString);
            } else {
                NSString *errorMessage = @"KCJSONParse received invalid UTF8 data";
                if (error) {
                    *error = KCErrorWithMessage(errorMessage);
                } else {
                    KCLog(@"%@", errorMessage);
                }
                return nil;
            }
        }
        NSJSONReadingOptions options = NSJSONReadingAllowFragments;
        if (mutable) {
            options |= NSJSONReadingMutableContainers;
        }
        return [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:options
                                                 error:error];
    }
    return nil;
}

id KCJSONParse(NSString *aJsonString, NSError **error)
{
    return _KCJSONParse(aJsonString, NO, error);
}

id KCJSONParseMutable(NSString *aJsonString, NSError **error)
{
    return _KCJSONParse(aJsonString, YES, error);
}

id KCJSONClean(id object)
{
    static dispatch_once_t onceToken;
    static NSSet<Class> *validLeafTypes;
    dispatch_once(&onceToken, ^{
        validLeafTypes = [[NSSet alloc] initWithArray:@[
                                                        [NSString class],
                                                        [NSMutableString class],
                                                        [NSNumber class],
                                                        [NSNull class],
                                                        ]];
    });
    
    if ([validLeafTypes containsObject:[object classForCoder]]) {
        return object;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        __block BOOL copy = NO;
        NSMutableDictionary<NSString *, id> *values = [[NSMutableDictionary alloc] initWithCapacity:[object count]];
        [object enumerateKeysAndObjectsUsingBlock:^(NSString *key, id item, __unused BOOL *stop) {
            id value = KCJSONClean(item);
            values[key] = value;
            copy |= value != item;
        }];
        return copy ? values : object;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        __block BOOL copy = NO;
        __block NSArray *values = object;
        [object enumerateObjectsUsingBlock:^(id item, NSUInteger idx, __unused BOOL *stop) {
            id value = KCJSONClean(item);
            if (copy) {
                [(NSMutableArray *)values addObject:value];
            } else if (value != item) {
                // Converted value is different, so we'll need to copy the array
                values = [[NSMutableArray alloc] initWithCapacity:values.count];
                for (NSUInteger i = 0; i < idx; i++) {
                    [(NSMutableArray *)values addObject:object[i]];
                }
                [(NSMutableArray *)values addObject:value];
                copy = YES;
            }
        }];
        return values;
    }
    
    return (id)kCFNull;
}





//@end
