//
//  KCClassMrg.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCClass.h"


@interface KCClassMrg : NSObject

+ (BOOL)registClass:(KCClass *)aClass;
+ (BOOL)registClass:(Class)aClass withJSObjName:(NSString *)aJSObjName;
+ (void)removeClass:(NSString *)aJSObjName;
+ (KCClass *)getClass:(NSString *)aJSObjName;

@end
