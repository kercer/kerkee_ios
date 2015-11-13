//
//  KCClass.h
//  kerkee
//
//  Created by zihong on 2015-11-10.
//  Copyright © 2015 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"
#import "KCMethod.h"

@interface KCClass : NSObject

+ (KCClass *)newClass:(Class)aClass withJSObjName:(NSString *)aJSClzName;

- (Class)getNavClass;
- (NSString *)getJSClz;

- (void)loadMethods;

- (void)addJSMethod:(NSString *)aJSMethodName args:(KCArgList *)aArgList;
- (NSArray*)getMethods:(NSString *)aJSMethodName;

@end
