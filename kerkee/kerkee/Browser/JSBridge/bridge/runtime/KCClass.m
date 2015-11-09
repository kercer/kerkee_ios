//
//  KCClass.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCClass.h"
#import "KCBaseDefine.h"

@interface KCClass()

@property (nonatomic, copy) NSString *mJSClzName;
@property (nonatomic, copy) NSString *mClassName;
@property (nonatomic, retain) Class mClz;
@property (nonatomic, retain) NSMutableDictionary *mMethods;

@end

@implementation KCClass

+ (KCClass *)newClass:(Class)aClass withJSObjName:(NSString *)aJSClzName
{
    KCClass *clz = [[self alloc] init];
    
    clz.mJSClzName = aJSClzName;
    clz.mClz = aClass;
    
    KCAutorelease(clz);
    return clz;
}

- (id)init
{
    self = [super init];
    if(self){
        _mMethods = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    
    return self;
}
 
- (void)dealloc
{
    self.mJSClzName = nil;
    self.mClassName = nil;
    self.mClz = nil;
    self.mMethods = nil;
    
    KCDealloc(super);
}

- (Class)getNavClass
{
    return self.mClz;
}

- (NSString *)getJSClz
{
    return self.mJSClzName;
}

- (void)addMethod:(NSString *)aMethodName args:(KCArgList *)aArgList
{
    //to do
    KCMethod *method = [KCMethod initWithName:aMethodName andMethod:NSSelectorFromString(aMethodName) andArgs:aArgList];
    
    [self.mMethods setObject:method forKeyedSubscript:aMethodName];
}

- (KCMethod *)getMethods:(NSString *)aName
{
    return [self.mMethods objectForKey:aName];
}

@end
