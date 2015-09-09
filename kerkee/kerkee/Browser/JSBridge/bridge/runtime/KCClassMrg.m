//
//  KCClassMrg.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCClassMrg.h"
#import "KCApiBridgeManager.h"
#import "KCApiBridge.h"
#import "KCXMLHttpRequestDispatcher.h"
#import "KCJSDefine.h"
#import "KCBaseDefine.h"

@interface KCClassMrg()

@property (nonatomic, retain) NSMutableDictionary *mClassMap;
@property (nonatomic, retain) NSMutableDictionary *mMethodCache;

@end



@implementation KCClassMrg

__attribute__((constructor))
static void initializeClassMap()
{
    [KCClassMrg registClass:[KCApiBridgeManager class] withJSObjName:kJS_jsBridgeClient];
    [KCClassMrg registClass:[KCApiBridge class] withJSObjName:kJS_ApiBridge];
    [KCClassMrg registClass:[KCXMLHttpRequestDispatcher class] withJSObjName:kJS_XMLHttpRequest];
}

+ (KCClassMrg *)shareInstance
{
    static KCClassMrg *gKCClassMgr = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        gKCClassMgr = [[KCClassMrg alloc] init];
    });
    
    return gKCClassMgr;
}

- (id)init
{
    self = [super init];
    if(self){
        _mClassMap = [[NSMutableDictionary alloc] initWithCapacity:20];
        _mMethodCache = [[NSMutableDictionary alloc] initWithCapacity:20];
    }

    return self;
}

- (void)dealloc
{
    self.mClassMap = nil;
    self.mMethodCache = nil;
    
    KCDealloc(super);
}

+ (BOOL)registClass:(KCClass *)aClass;
{
    return [KCClassMrg registClass:[aClass getNavClass] withJSObjName:[aClass getJSClz]];
}

//NSStringFromClass
//NSClassFromString
//NSStringFromSelector
//NSStringFromProtocol
//class_getName
+ (BOOL)registClass:(Class)aClass withJSObjName:(NSString *)aJSObjName
{
    if(nil == aClass || nil == aJSObjName)
        return NO;
    
    if(NO == [[[KCClassMrg shareInstance].mClassMap allValues] containsObject:aClass])
    {
        [[KCClassMrg shareInstance].mClassMap setObject:[KCClass initWithClass:aClass clzName:aJSObjName] forKey:aJSObjName];
        return YES;
    }
    
    return NO;
}


+ (void)removeClass:(NSString *)aJSObjName
{
    if(nil == aJSObjName)
    {
        return;
    }
    
    if(NO == [[[KCClassMrg shareInstance].mClassMap allKeys] containsObject:aJSObjName])
    {
        [[KCClassMrg shareInstance].mClassMap removeObjectForKey:aJSObjName];
    }
    
    return;
}

+ (KCClass *)getClass:(NSString *)aJSObjName
{
    return [[KCClassMrg shareInstance].mClassMap objectForKey:aJSObjName];
}

@end
