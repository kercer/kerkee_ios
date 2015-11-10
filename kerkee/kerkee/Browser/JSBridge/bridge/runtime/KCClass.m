//
//  KCClass.m
//  kerkee
//
//  Created by zihong on 2015-11-10.
//  Copyright © 2015 zihong. All rights reserved.
//

#import "KCClass.h"
#import "KCBaseDefine.h"

@interface KCClass()
{
    NSString* m_jsClzName;
    Class m_clz;
    NSMutableDictionary* m_methods;
}


@end

@implementation KCClass

+ (KCClass *)newClass:(Class)aClass withJSObjName:(NSString *)aJSClzName
{
    KCClass *clz = [[self alloc] init];
    
    clz->m_jsClzName = aJSClzName;
    clz->m_clz = aClass;
    
    KCAutorelease(clz);
    return clz;
}

- (id)init
{
    self = [super init];
    if(self){
        m_methods = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    
    return self;
}
 
- (void)dealloc
{
    KCRelease(m_jsClzName);
    m_jsClzName = nil;
    KCRelease(m_clz);
    m_clz = nil;
    KCRelease(m_methods);
    m_methods = nil;
    
    KCDealloc(super);
}

- (Class)getNavClass
{
    return m_clz;
}

- (NSString*)getJSClz
{
    return m_jsClzName;
}

- (void)addJSMethod:(NSString *)aJSMethodName args:(KCArgList *)aArgList
{
//    KCMethod *method = [KCMethod createMethod:NSSelectorFromString(aJSMethodName)];
//    
//    [m_methods setObject:method forKeyedSubscript:aJSMethodName];
}

- (KCMethod *)getMethods:(NSString *)aName
{
    return [m_methods objectForKey:aName];
}

@end
