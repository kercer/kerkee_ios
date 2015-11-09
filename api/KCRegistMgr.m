//
//  KCRegistMgr.m
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "KCRegistMgr.h"


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
        
        //registArray = NSMutableArray
        
        registObjArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

+ (void)registAllClass
{
    [KCJSBridge registClass:[KCChannelModuleApi class] jsObjName:@"channelModule"];
    [KCJSBridge registClass:[KCClientInfoApi class] jsObjName:@"clientInfo"];
    [KCJSBridge registClass:[KCClientUI class] jsObjName:@"clientUI"];
    [KCJSBridge registClass:[KCSearchApi class] jsObjName:@"searchModules"];
    [KCJSBridge registClass:[KCWidget class] jsObjName:@"widget"];
    
    //have rewritten jsBridgeClient in kerkee
    [KCJSBridge registJSBridgeClient:[KCApiOverrideJSBridgeClient class]];
    [KCJSBridge registClass:[KCApiTest class] jsObjName:@"testModule"];

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
