//
//  KCMethod.m
//  kerkee
//
//  Created by zihong on 15/11/10.
//  Copyright © 2015年 zihong. All rights reserved.
//


#import "KCMethod.h"
#import "KCBaseDefine.h"
#import "NSObject+KCSelector.h"
#import <objc/runtime.h>

@interface KCMethod()
{
    NSString* m_jsMethodName;
    SEL m_method;
    NSString* m_indentity;
    
    KCModifier* m_modifier;
}

@end


@implementation KCMethod

+ (KCMethod *)createMethod:(SEL)aMethod modifier:(KCModifier*)aModifier
{
    KCMethod *mtd = [[self alloc] initWithSEL:aMethod modifier:(KCModifier*)aModifier];
    KCAutorelease(mtd);
    return mtd;
}


- (id)initWithSEL:(SEL)aMethod modifier:(KCModifier*)aModifier
{
    if (self = [super init])
    {
        NSString *selectorString = NSStringFromSelector(aMethod);
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        m_method = aMethod;
        m_jsMethodName = components[0];
        
        m_modifier = aModifier ? aModifier : [[KCModifier alloc] init];
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_jsMethodName);
    m_jsMethodName = nil;
    m_method = nil;
    KCRelease(m_indentity);
    m_indentity = nil;
    
    KCDealloc(super);
}

- (NSString *)createIdentity:(NSString *)aClzName methodName:(NSString *)aMethodName argsKeys:(NSArray *)aArgsKeys
{
    return [NSString stringWithFormat:@"%@_%@_%@",aClzName,aMethodName,@""];
}

- (NSString *)getIdentity
{
    return m_indentity;
}

- (SEL)getNavMethod
{
    return m_method;
}

- (NSString*)getJSMethodName
{
    return m_jsMethodName;
}

- (BOOL)isSameMethod:(SEL)aMethod modifier:(KCModifier*)aModifier
{
    return sel_isEqual(aMethod, m_method) && [m_modifier isEqual:aModifier];
}

- (KCModifier*)modifier
{
    return m_modifier;
}

- (BOOL)isStatic
{
    return [m_modifier isStatic];
}

- (id)invoke:(id)aReceiver, ...
{
    id result = nil;
    if (aReceiver)
    {
        va_list args;
        va_start(args, aReceiver);
        result = [aReceiver performSelectorSafetyWithArgs:m_method arguments:args];
        va_end(args);
    }
    
    return result;
}


@end
