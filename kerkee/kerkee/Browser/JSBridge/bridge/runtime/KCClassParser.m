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

#define kCP_ClassName       (@"clz")
#define kCP_MethodName      (@"method")
#define kCP_Args            (@"args")

@interface KCClassParser()


@property (nonatomic, copy) NSString    *m_clsName;
@property (nonatomic, copy) NSString    *m_methodName;
@property (nonatomic, retain) KCArgList   *m_argList;

@end

@implementation KCClassParser


+ (KCClassParser *)createParser:(NSDictionary *)dic
{
    KCClassParser *parser = [[KCClassParser alloc] init];
    if(parser)
    {
        parser.m_clsName = [dic objectForKey:kCP_ClassName];
        parser.m_methodName = [dic objectForKey:kCP_MethodName];
        NSDictionary *args = [dic objectForKey:kCP_Args];
        if(nil != args)
        {
            parser.m_argList = [self convertToArgList:args];
        }
    }
    
    KCAutorelease(parser);
    return parser;
}

- (void)dealloc
{
    self.m_clsName = nil;
    self.m_methodName = nil;
    self.m_argList = nil;
    
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
        
        [list addArg:[KCArg initWithObject:obj key:key]];
    }
    
    KCAutorelease(list);
    return list;
}


- (NSString *)getJSClzName
{
    return self.m_clsName;
}
- (NSString *)getJSMethodName
{
    return self.m_methodName;
}
- (KCArgList *)getArgList
{
    return self.m_argList;
}

@end
