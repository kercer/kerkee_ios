//
//  KCArgList.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCArgList.h"
#import "KCBaseDefine.h"

@interface KCArgList()
@property (nonatomic, retain)NSMutableDictionary *m_Args;

@end

@implementation KCArgList

- (id)init
{
    self = [super init];
    if(self)
    {
        _m_Args = [[NSMutableDictionary alloc] initWithCapacity:20];
     }
    
    return self;
}

- (void)dealloc
{
    self.m_Args = nil;
    
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

- (BOOL) addArg:(KCArg *)aArg
{
    if(nil == aArg)
    {
        return NO;
    }
    
    [_m_Args setObject:aArg forKey:[aArg getArgName]];
    
    //KCLog(@"Arg--%@",[aArg toString]);
    
    return YES;
}


- (id) getArgValule:(NSString *)aKey
{
    if(nil == aKey)
    {
        return nil;
    }
    
    KCArg *arg = [_m_Args objectForKey:aKey];
    if(nil == arg)
    {
        return nil;
    }
    
    return [arg getValue];
}



- (NSString *)getArgValueString:(NSString *)aKey
{
    id obj = [self getArgValule:aKey];
    if(nil == obj)
    {
        return nil;
    }
    
    return ([obj isKindOfClass:[NSString class]])?(obj):([obj toString]);;
}

- (NSString *)toString
{
    if(nil == _m_Args || [_m_Args count] <= 0)
        return nil;
    
    __block NSMutableString *str = [NSMutableString string];
    [_m_Args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [str appendString:[[KCArg initWithObject:obj key:key] toString]];
        [str appendString:@";"];
    }];
    
    return str;
}

- (NSInteger)count
{
    return [_m_Args count];
}

@end


