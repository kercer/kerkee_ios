//
//  KCMethod.h
//  kerkee
//
//  Created by zihong on 15/11/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"
#import "KCModifier.h"

@interface KCMethod : NSObject

+ (KCMethod *)createMethod:(SEL)aMethod modifier:(KCModifier*)aModifier;

- (NSString *)createIdentity:(NSString *)aClzName methodName:(NSString *)aMethodName argsKeys:(NSArray *)aArgsKeys;
- (NSString *)getIdentity;
- (SEL)getNavMethod;
- (NSString*)getJSMethodName;
- (BOOL)isSameMethod:(SEL)aMethod modifier:(KCModifier*)aModifier;

- (KCModifier*)modifier;
- (BOOL)isStatic;

// arg list can support internal types
- (id)invoke:(id)aReceiver, ...;

@end
