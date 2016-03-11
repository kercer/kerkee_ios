//
//  KCRegistObj.m
//  kerkee
//
//  Designed by zihong
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.

#import "KCRegistMgr.h"
#import "KCJSObjDefine.h"

#import "KCApiClientInfo.h"
#import "KCClientUI.h"
#import "KCWidget.h"
#import "KCApiTest.h"
#import "KCApiOverrideJSBridgeClient.h"
#import "KCApiJSObjExample.h"

#import "KCJSDefine.h"

@implementation KCRegistObj



@end


@interface KCRegistMgr()
{
    NSMutableArray *registObjArray;
}

@end

@implementation KCRegistMgr

+ (id)shareInstance
{
    static KCRegistMgr *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[KCRegistMgr alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(nil != self){
        registObjArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

+ (void)registAllClass
{
    //for test
    [KCJSBridge registClass:[KCApiClientInfo class] jsObjName:@"clientInfo"];
    [KCJSBridge registClass:[KCClientUI class] jsObjName:@"clientUI"];
    [KCJSBridge registClass:[KCWidget class] jsObjName:@"widget"];
    
    //have rewritten jsBridgeClient in kerkee
    //you can use this way, first you can import "KCJSDefine.h"
    //[KCJSBridge registClass:[KCApiOverrideJSBridgeClient class] jsObjName:kJS_jsBridgeClient];
    [KCJSBridge registJSBridgeClient:[KCApiOverrideJSBridgeClient class]];
    [KCJSBridge registClass:[KCApiTest class] jsObjName:kJS_TestModule];
    
    //you can regist class which inherit from KCJSObject,js call static function
    //[KCJSBridge registClass:[KCApiJSObjExample class] jsObjName:kJS_JSObjExampleModule];
    [KCJSBridge registObject:[[KCApiJSObjExample alloc]init] ];

}


- (void)registJSInterface:(NSString *)interfaceName obj:(id)instanceObj
{
    KCRegistObj *rgtObj = [[KCRegistObj alloc] init];
    
    rgtObj.interfaceName = interfaceName;
    rgtObj.instanceObj = instanceObj;
    
    [registObjArray addObject:rgtObj];
}

- (void)unRegistJSInterface:(NSString *)interfaceName obj:(id)instanceObj
{
    if(nil == instanceObj || nil == interfaceName)
        return;
    
    for (KCRegistObj *obj in registObjArray) {
        if(obj.instanceObj == instanceObj && [interfaceName isEqualToString:obj.interfaceName]){
            [registObjArray removeObject:obj];
        }
    }
}

//[clz performSelector:method withObject:webView withObject:argList];
- (void)performMethod:(NSString *)method withObject:(KCWebView *)webView withParam:(KCArgList *)arglist
{
    
}
@end
