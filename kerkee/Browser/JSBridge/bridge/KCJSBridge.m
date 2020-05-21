//
//  KCJSBridge.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCJSBridge.h"
#import "KCBaseDefine.h"
#import "KCApiBridge.h"
#import "KCClass.h"
#import "KCJSExecutor.h"
#import "KCJSDefine.h"

@interface KCJSBridge()
{
    KCApiBridge* m_apiBridge;
}

@end

@implementation KCJSBridge

- (id)initWithWebView:(KCWebView *)aWebView delegate:(id)delegate
{
    self = [super init];
    if(self)
    {
        m_apiBridge = [KCApiBridge apiBridgeWithWebView:aWebView delegate:delegate];
        KCRetain(m_apiBridge);
    }
    
    return self;
}

- (void)dealloc
{
    
    KCRelease(m_apiBridge);
    
    KCDealloc(super);
}

/********************************************************/
/*
 * js opt
 */
/********************************************************/
#pragma mark - register
+ (KCClass*)registJSBridgeClient:(Class)aClass
{
    return [KCRegister registClass:aClass withJSObjName:kJS_jsBridgeClient];
}

+ (KCClass*)registClass:(KCClass *)aClass
{
    return [KCRegister registClass:aClass];
}

+ (KCClass*)registClass:(Class)aClass jsObjName:(NSString *)aJSObjectName;
{
    return [KCRegister registClass:aClass withJSObjName:aJSObjectName];
}

+ (KCClass*)registObject:(KCJSObject*)aObject
{
    return [KCRegister registObject:aObject];
}
+ (KCClass*)removeObject:(KCJSObject*)aObject
{
    return [KCRegister removeObject:aObject];
}

+ (KCClass*)removeClass:(NSString*)aJSObjName
{
    return [KCRegister removeClass:aJSObjName];
}

+ (KCClass*)getClass:(NSString*)aJSObjName
{
    return [KCRegister getClass:aJSObjName];
}


/********************************************************/
/*
 * config
 */
/********************************************************/
+ (void)openGlobalJSLog:(BOOL)aIsOpenJSLog
{
    [KCApiBridge openGlobalJSLog:aIsOpenJSLog];
}

+ (void)setIsOpenJSLog:(KCWebView*)aWebview isOpenJSLog:(BOOL)aIsOpenJSLog
{
    [KCApiBridge setIsOpenJSLog:aWebview isOpenJSLog:aIsOpenJSLog];
}



@end
