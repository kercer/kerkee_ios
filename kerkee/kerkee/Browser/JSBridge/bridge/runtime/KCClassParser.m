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

- (KCClassParser *)initWithJson:(NSString *)json
{
    self = [super init];
    if(self)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        _m_clsName = [dic objectForKey:kCP_ClassName];
        _m_methodName = [dic objectForKey:kCP_MethodName];
    }
    
    return self;
}

+ (KCClassParser *)initWithDictionary:(NSDictionary *)dic
{
    KCClassParser *parser = [[KCClassParser alloc] init];
    if(parser)
    {
        parser.m_clsName = [dic objectForKey:kCP_ClassName];
        parser.m_methodName = [dic objectForKey:kCP_MethodName];
        NSDictionary *args = [dic objectForKey:kCP_Args];
        if(nil != args)
        {
            parser.m_argList = [KCArgList convertToArgList:args];
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
