//
//  KCClass.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArgList.h"
#import "KCMethod.h"

@interface KCClass : NSObject

+ (KCClass *)newClass:(Class)aClass withJSObjName:(NSString *)aJSClzName;

- (Class)getNavClass;
- (NSString *)getJSClz;

- (void)addMethod:(NSString *)aMethodName args:(KCArgList *)aArgList;
- (KCMethod *)getMethods:(NSString *)aName;

@end
