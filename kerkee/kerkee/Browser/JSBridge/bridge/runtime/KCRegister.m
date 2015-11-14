//
//  KCRegister.m
//  kerkee
//
//  Created by zihong on 15/11/9.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCRegister.h"
#import "KCApiBridgeManager.h"
#import "KCApiBridge.h"
#import "KCXMLHttpRequestDispatcher.h"
#import "KCJSDefine.h"
#import "KCBaseDefine.h"
#import "KCTaskQueue.h"

@interface KCRegister()
{
    NSMutableDictionary* m_classMap;
    NSMutableDictionary* m_jsObjectMap;
}

AS_SINGLETON(KCRegister);

@end



@implementation KCRegister

DEF_SINGLETON(KCRegister);

__attribute__((constructor))
static void initializeClassMap()
{
    [[KCRegister sharedInstance] initializeJSObject];
}

- (void) initializeJSObject
{
    [self registClass:[KCApiBridgeManager class] withJSObjName:kJS_jsBridgeClient];
    [self registClass:[KCApiBridge class] withJSObjName:kJS_ApiBridge];
//    [self registClass:[KCXMLHttpRequestDispatcher class] withJSObjName:kJS_XMLHttpRequest];
    [self registObject:[[KCXMLHttpRequestDispatcher alloc] init]];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        m_classMap = [[NSMutableDictionary alloc] initWithCapacity:20];
        m_jsObjectMap = [[NSMutableDictionary alloc] initWithCapacity:20];
    }

    return self;
}

- (void)dealloc
{
    KCRelease(m_classMap);
    m_classMap = nil;
    
    KCDealloc(super);
}

+ (KCClass*)registObject:(KCJSObject*)aObject
{
   return [[KCRegister sharedInstance] registObject:aObject];
}

- (KCClass*)registObject:(KCJSObject*)aObject
{
    if (!aObject) return NULL;
    NSString* jsObjectName = [aObject getJSObjectName];
    KCClass* clz = NULL;
    if (jsObjectName)
    {
        [m_jsObjectMap setObject:aObject forKey:jsObjectName];
        clz = [self registClass:aObject.class withJSObjName:jsObjectName];
    }
    
    return clz;
}

+ (KCClass*)removeObject:(KCJSObject*)aObject
{
    return [[KCRegister sharedInstance] removeObject:aObject];
}
- (KCClass*)removeObject:(KCJSObject*)aObject
{
    if (!aObject) return NULL;
    NSString* jsObjectName = [aObject getJSObjectName];
    KCClass* clz = NULL;
    if(jsObjectName)
    {
        [m_jsObjectMap removeObjectForKey:jsObjectName];
        clz = [self removeClass:jsObjectName];
    }
    return clz;
}

+ (KCClass*)registClass:(KCClass *)aClass
{
    return [[KCRegister sharedInstance] registClass:aClass];
}

- (KCClass*)registClass:(KCClass *)aClass;
{
    return [self registClass:[aClass getNavClass] withJSObjName:[aClass getJSClz]];
}

+ (KCClass*)registClass:(Class)aClass withJSObjName:(NSString *)aJSObjName
{
    return [[KCRegister sharedInstance] registClass:aClass withJSObjName:aJSObjName];
}
- (KCClass*)registClass:(Class)aClass withJSObjName:(NSString *)aJSObjName
{
    if(nil == aClass || NULL == aJSObjName)
        return NULL;
    KCClass* clz = [KCClass newClass: aClass withJSObjName:aJSObjName];
    
    [m_classMap setObject:clz forKey:aJSObjName];
    
    BACKGROUND_GLOBAL_BEGIN(DISPATCH_QUEUE_PRIORITY_HIGH)
    [clz loadMethods];
    BACKGROUND_GLOBAL_COMMIT
    
    return clz;
}

+ (KCClass*)removeClass:(NSString *)aJSObjName
{
    return [[KCRegister sharedInstance] removeClass:aJSObjName];
}
- (KCClass*)removeClass:(NSString *)aJSObjName
{
    if(nil == aJSObjName)
    {
        return NULL;
    }
    
    KCClass* clz = [m_classMap objectForKey:aJSObjName];
    if(clz)
    {
        [m_classMap removeObjectForKey:aJSObjName];
    }
    
    return clz;
}

+ (KCClass *)getClass:(NSString *)aJSObjName
{
    return [[KCRegister sharedInstance] getClass:aJSObjName];
}
- (KCClass *)getClass:(NSString *)aJSObjName
{
    return [m_classMap objectForKey:aJSObjName];
}

+ (KCJSObject*)getJSObject:(NSString*)aJSObjName
{
    return [[KCRegister sharedInstance] getJSObject:aJSObjName];
}
- (KCJSObject*)getJSObject:(NSString*)aJSObjName
{
    return [m_jsObjectMap objectForKey:aJSObjName];
}

@end
