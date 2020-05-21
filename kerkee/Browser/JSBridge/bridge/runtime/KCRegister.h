//
//  KCRegister.h
//  kerkee
//
//  Created by zihong on 15/11/9.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCClass.h"
#import "KCJSObject.h"

@interface KCRegister : NSObject

+ (KCClass*)registObject:(KCJSObject*)aObject;
+ (KCClass*)removeObject:(KCJSObject*)aObject;
+ (KCClass*)registClass:(KCClass*)aClass;
+ (KCClass*)registClass:(Class)aClass withJSObjName:(NSString*)aJSObjName;
+ (KCClass*)removeClass:(NSString*)aJSObjName;
+ (KCClass*)getClass:(NSString*)aJSObjName;
+ (KCJSObject*)getJSObject:(NSString*)aJSObjName;

@end
