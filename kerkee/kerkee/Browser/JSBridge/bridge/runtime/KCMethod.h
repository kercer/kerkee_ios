//
//  KCMethod.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"

@interface KCMethod : NSObject

+ (KCMethod *)initWithName:(NSString *)aName andMethod:(SEL)aMethod andArgs:(KCArgList *)aArgs;

- (NSString *)createIdentity:(NSString *)aClzName methodName:(NSString *)aMethodName argsKeys:(NSArray *)aArgsKeys;
- (NSString *)getIdentity;
- (SEL)getNavMethod;

@end
