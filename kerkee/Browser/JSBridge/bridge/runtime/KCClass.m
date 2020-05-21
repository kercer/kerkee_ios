//
//  KCClass.m
//  kerkee
//
//  Created by zihong on 2015-11-10.
//  Copyright © 2015 zihong. All rights reserved.
//

#import "KCClass.h"
#import "KCBaseDefine.h"
#import "NSObject+KCObjectInfo.h"
#import "KCTaskQueue.h"

@interface KCClass()
{
    NSString* m_jsClzName;
    Class m_clz;
    
    //the key is js method name, the value is KCMethod list
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

//return KCMethod list
- (NSArray*)getMethods:(NSString *)aJSMethodName
{
    return [self getMutableMethods:aJSMethodName];
}

- (NSMutableArray*)getMutableMethods:(NSString*)aName
{
    return [m_methods objectForKey:aName];
}

- (void)loadMethods
{
    unsigned int num;
    Class clz = objc_getMetaClass(m_clz.description.UTF8String);
    Method *methods = class_copyMethodList(clz, &num);
    for (int i = 0; i < num; i++)
    {
        KCModifier* modifier = [[KCModifier alloc] init];
        [modifier markStatic];
        [self loadMethod:methods[i] modifier:modifier];
    }
    free(methods);
    
    
    Method* objMethods = class_copyMethodList(m_clz.class, &num);
    for (int i = 0; i < num; i++)
    {
        KCModifier* modifier = [[KCModifier alloc] init];
        [self loadMethod:objMethods[i] modifier:modifier];
    }
    free(objMethods);
}

- (KCMethod*)loadMethod:(Method)aMethod modifier:(KCModifier*)aModifier
{
    SEL methodSel = method_getName(aMethod);
    NSArray *components = [NSStringFromSelector(methodSel) componentsSeparatedByString:@":"];
    NSString* methodName = components[0];
    
    NSMutableArray* listMethods = [self getMutableMethods:methodName];
    if ( !listMethods )
    {
        listMethods = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    KCMethod* jsMethod = NULL;
    for(int i = 0; i < [listMethods count]; ++i)
    {
        KCMethod* tmpMethod = listMethods[i];
        if ( !tmpMethod ) continue;
        if ([tmpMethod isSameMethod:methodSel modifier:aModifier])
        {
            jsMethod = tmpMethod;
        }
    }
    
    if ( !jsMethod )
    {
        jsMethod = [KCMethod createMethod:methodSel modifier:aModifier];
        [listMethods addObject:jsMethod];
        [m_methods setObject:listMethods forKey:methodName];
    }
    return jsMethod;
}

@end
