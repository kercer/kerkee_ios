//
//  KCMethod.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCMethod.h"
#import "KCBaseDefine.h"

@interface KCMethod()

@property (nonatomic, copy) NSString *mJSMethodName;
@property (nonatomic, assign) SEL mMethod;
@property (nonatomic, copy) NSString *mIdentity;

@property (nonatomic, retain) KCArgList *mArgList;

@end


@implementation KCMethod

+ (KCMethod *)initWithName:(NSString *)aName andMethod:(SEL)aMethod andArgs:(KCArgList *)aArgs
{
    KCMethod *mtd = [[self alloc] init];
    
    mtd.mMethod = aMethod;
    mtd.mJSMethodName = aName;
    mtd.mArgList = aArgs;
    
    KCAutorelease(mtd);
    return mtd;
}

- (void)dealloc
{
    self.mJSMethodName = nil;
    self.mMethod = nil;
    self.mIdentity = nil;
    self.mArgList = nil;
    
    KCDealloc(super);
}

- (NSString *)createIdentity:(NSString *)aClzName methodName:(NSString *)aMethodName argsKeys:(NSArray *)aArgsKeys
{
    return [NSString stringWithFormat:@"%@_%@_%@",aClzName,aMethodName,@""];
}

- (NSString *)getIdentity
{
    return self.mIdentity;
}

- (SEL)getNavMethod
{
    return self.mMethod;
}

/*
public int getArgsCount()
{
    return mMethod.getParameterTypes().length;
}

public Object invoke(Object aReceiver, Object... aArgs) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException
{
    return mMethod.invoke(aReceiver, aArgs);
}

*/

@end
