//
//  NSObject+KCCoding.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCCoding.h"
#import <objc/runtime.h>
#import "KCLog.h"
#import "KCBaseDefine.h"

#import <objc/message.h>  //new realize


@implementation NSObject (KCCoding)


#pragma mark -
- (void)encodeAutoWithCoder:(NSCoder *)aCoder class:(Class)class
{
    unsigned int outCount = 0;
    objc_property_t *pt = class_copyPropertyList(class, &outCount);
    for (int i = 0; i< outCount; i++)
    {
        objc_property_t property = pt[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL selector = NSSelectorFromString(name);
        Method mt = class_getInstanceMethod(class, selector);
        if (mt != NULL)
        {
            NSString *returnType = [class getMethodReturnType:mt];
            switch ([returnType characterAtIndex:0])
            {
                case 'i':
                {
                    @try
                    {
                        int intValue = ((int(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@ int value:%d", NSStringFromClass(class), name, intValue);
                        
                        [aCoder encodeInteger:intValue forKey:name];
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }
                }
                    break;
                case 'l': //long
                case 'q': //long long
                case 'L': //unsigned long
                case 'Q': //unsigned long long
                {
                    @try
                    {
                        long long llValue = ((long long(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@ longlong value:%d", NSStringFromClass(class), name, llValue);
                        
                        [aCoder encodeInt64:llValue forKey:name];
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }

                }
                    break;
                case 'I': //unsigned
                {
                    @try
                    {
                        unsigned intValue = ((unsigned(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@ int value:%d", NSStringFromClass(class), name, intValue);
                        
                        [aCoder encodeInteger:intValue forKey:name];
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }

                }
                    break;
                case 'f': //float
                case 'd': //double
                {
                    @try
                    {
                        double doubleValue = ((double(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@ double value:%.f", NSStringFromClass(class), name, doubleValue);
                        
                        [aCoder encodeDouble:doubleValue forKey:name];
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }
                }
                    break;
                case 'c': //bool
                {
                    @try
                    {
                        // char 一般为BOOL, property不用char即可
                        BOOL boolValue = ((char(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@ BOOL value:%d", NSStringFromClass(class), name, boolValue);
                        
                        [aCoder encodeBool:boolValue forKey:name];
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }

                }
                    break;
                case '@':
                default:
                {
                    @try
                    {
                        id value = ((id(*)(id, Method))method_invoke)(self, mt);
                        KCLog(@"Encode %@ %@  value:%@", NSStringFromClass(class), name, value);
                        
                        [aCoder encodeObject:value forKey:name];
//                        // only decode if the property conforms to NSCoding
//                        if([class conformsToProtocol:@protocol(NSCoding)])
//                        {
//                            [aCoder encodeObject:value forKey:name];
//                        }
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Encode Return Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, returnType);
                    }
                    @finally
                    {
                    }
                }
                    break;
            }
        }
    }
    free(pt);
}

- (void)encodeAutoWithCoder:(NSCoder *)aCoder
{
    [self encodeAutoWithCoder:aCoder class:[self class]];
}

- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder class:(Class)class
{
    unsigned int outCount = 0;
    objc_property_t *pt = class_copyPropertyList(class, &outCount);
    for (int i = 0; i< outCount; i++)
    {
        objc_property_t property = pt[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL selector = NSSelectorFromString([class getSetMethodName:name]);
        Method mt = class_getInstanceMethod(class, selector);
        if (mt != NULL)
        {
            NSString *argumentType = [class getMethodArgumentType:mt index:2];
//            KCLog(@"\n\n*******************\n%@:%@\n*******************\n\n", name, argumentType);
            switch ([argumentType characterAtIndex:0])
            {
                case 'i': //int
                {
                    @try
                    {
                        int intValue = (int)[aDecoder decodeIntegerForKey:name];
                        void (*method_invokeTyped)(id self, Method mt, int value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, intValue);
                        
                        KCLog(@"Decode %@ %@  intValue:%d", NSStringFromClass(class), name, intValue);
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }

                }
                    break;
                case 'l': //long
                case 'q': //long long
                case 'L': //unsigned long
                case 'Q': //unsigned long long
                {
                    @try
                    {
                        long long llValue = [aDecoder decodeInt64ForKey:name];
                        void (*method_invokeTyped)(id self, Method mt, long long value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, llValue);
                        
                        KCLog(@"Decode %@ %@  llValue:%d", NSStringFromClass(class), name, llValue);
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }
                }
                    break;
                case 'I': //unsigned
                {
                    @try
                    {
                        unsigned intValue = (unsigned)[aDecoder decodeIntegerForKey:name];
                        void (*method_invokeTyped)(id self, Method mt, unsigned value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, intValue);
                        
                        KCLog(@"Decode %@ %@   unsigned intValue:%d", NSStringFromClass(class), name, intValue);
                        
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }
                }
                    break;
                case 'f': //float
                case 'd': //double
                {
                    @try
                    {
                        double doubleValue = [aDecoder decodeDoubleForKey:name];
                        void (*method_invokeTyped)(id self, Method mt, double value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, doubleValue);
                        
                        KCLog(@"Decode %@ %@  doubleValue:%f", NSStringFromClass(class), name, doubleValue);
                        
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }

                }
                    break;
                case 'c': //bool
                {
                    @try
                    {
                        // char 一般为BOOL, property不用char即可
                        BOOL boolValue = [aDecoder decodeBoolForKey:name];
                        void (*method_invokeTyped)(id self, Method mt, BOOL value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, boolValue);
                        
                        KCLog(@"Decode %@ %@  boolValue:%d", NSStringFromClass(class), name, boolValue);
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }
                }
                    break;
                case '@':
                default:
                {
                    @try
                    {
                        id value = [aDecoder decodeObjectForKey:name];
                        if (value != nil)
                        {
                            void (*method_invokeTyped)(id self, Method mt, id aValue) = (void*)method_invoke;
                            method_invokeTyped(self, mt, value);                            
//                            method_invoke(self, mt, value);
                            
                        }
                        
                        
                        KCLog(@"Decode %@ %@  value(%@):%@", NSStringFromClass(class), name, NSStringFromClass([value class]), value);
                    }
                    @catch (NSException *exception)
                    {
                        KCLog(@"Decode Argument Value Type undefined in %@, %@ for %@", NSStringFromClass(class), name, argumentType);
                    }
                    @finally
                    {
                    }
                }
                    break;
            }
        }
    }
    free(pt);
}

- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder
{
    [self decodeAutoWithAutoCoder:aDecoder class:[self class]];
}
+ (NSString *)getMethodReturnType:(Method)mt
{
    char dstType[10] = {0};
    size_t dstTypeLen = 10;
    method_getReturnType(mt, dstType, dstTypeLen);
    return [NSString stringWithUTF8String:dstType];
}

+ (NSString *)getMethodArgumentType:(Method)mt index:(NSInteger)index
{
    char dstType[10] = {0};
    size_t dstTypeLen = 10;
    method_getArgumentType(mt, (unsigned int)index, dstType, dstTypeLen);
    return [NSString stringWithUTF8String:dstType];
}

+ (NSString *)getSetMethodName:(NSString *)propertyName
{
    if ([propertyName length] == 0)
        return @"";
    
    NSString *firstChar = [propertyName substringToIndex:1];
    firstChar = [firstChar uppercaseString];
    NSString *lastName = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstChar, lastName];
}

@end