//
//  KCClassParser.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCClassParser.h"
#import "KCBaseDefine.h"
#import "KCJSDefine.h"
#import "KCJSCallback.h"

#define kCP_ClassName       (@"clz")
#define kCP_MethodName      (@"method")
#define kCP_Args            (@"args")

@interface KCClassParser()
{
    NSString    *m_clsName;
    NSString    *m_methodName;
    KCArgList   *m_argList;
}

@end

@implementation KCClassParser


+ (KCClassParser *)createParser:(NSDictionary *)dic
{
    KCClassParser *parser = [[KCClassParser alloc] init];
    if(parser)
    {
        parser->m_clsName = [dic objectForKey:kCP_ClassName];
        parser->m_methodName = [dic objectForKey:kCP_MethodName];
        NSDictionary *args = [dic objectForKey:kCP_Args];
        if(nil != args)
        {
            parser->m_argList = [self convertToArgList:args];
        }
    }
    
    KCAutorelease(parser);
    return parser;
}

- (void)dealloc
{
    m_clsName = nil;
    m_methodName = nil;
    m_argList = nil;
    
    KCDealloc(super);
}


+ (KCArgList *)convertToArgList:(NSDictionary *)dic
{
    KCArgList *list = [[KCArgList alloc] init];
    
    NSInteger count = [dic count];
    __unsafe_unretained id objs[count];
    __unsafe_unretained id keys[count];
    [dic getObjects:objs andKeys:keys];
    for (NSInteger i = 0; i < count; i++)
    {
        __unsafe_unretained id obj = objs[i];
        __unsafe_unretained id key = keys[i];
        
        id value = obj;
        if ([key isEqualToString:kJS_callbackId])
        {
            value = [[KCJSCallback alloc] initWithCallbackId:obj];
        }
        
        KCArg* arg = [[KCArg alloc] initWithObject:value name:key];
        
        [list addArg:arg];
    }
    
    KCAutorelease(list);
    return list;
}


- (NSString *)getJSClzName
{
    return m_clsName;
}
- (NSString *)getJSMethodName
{
    return m_methodName;
}
- (KCArgList *)getArgList
{
    return m_argList;
}

@end
