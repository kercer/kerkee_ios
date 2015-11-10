//
//  KCMethod.h
//  kerkee
//
//  Created by zihong on 15/11/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"

@interface KCMethod : NSObject

+ (KCMethod *)createMethod:(SEL)aMethod;

- (NSString *)createIdentity:(NSString *)aClzName methodName:(NSString *)aMethodName argsKeys:(NSArray *)aArgsKeys;
- (NSString *)getIdentity;
- (SEL)getNavMethod;
- (NSString*)getJSMethodName;

@end
