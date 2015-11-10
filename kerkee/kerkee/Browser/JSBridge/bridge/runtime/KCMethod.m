//
//  KCMethod.m
//  kerkee
//
//  Created by zihong on 15/11/10.
//  Copyright © 2015年 zihong. All rights reserved.
//


#import "KCMethod.h"
#import "KCBaseDefine.h"

@interface KCMethod()
{
    NSString* m_jsMethodName;
    SEL m_method;
    NSString* m_indentity;
}

@end


@implementation KCMethod

+ (KCMethod *)createMethod:(SEL)aMethod
{
    KCMethod *mtd = [[self alloc] init];
    
    NSString *selectorString = NSStringFromSelector(aMethod);
    NSArray *components = [selectorString componentsSeparatedByString:@":"];
    
    mtd->m_method = aMethod;
    mtd->m_jsMethodName = components[0];
    KCAutorelease(mtd);
    return mtd;
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


@end
