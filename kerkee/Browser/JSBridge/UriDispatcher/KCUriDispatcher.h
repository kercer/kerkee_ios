//
//  KCUriDispatcher.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCURI.h"
#import "KCUriRegister.h"

@interface KCUriDispatcher : NSObject

+(void)dispatcher:(NSString*)aUriString;


#pragma mark -
#pragma mark KCUriRegister

/**
 * before call defaultUriRegister,should set setDefaultScheme
 * @param aScheme
 */
+(KCUriRegister*)markDefaultRegister:(NSString*)aScheme;

/**
 if you call markDefaultRegister to set defaultUriRegister once before you call defaultUriRegister
 */
+(KCUriRegister*)defaultUriRegister;

/**
 get uri register with scheme,if you get default uri register,you can use defaultUriRegister method
 */
+(KCUriRegister*)getUriRegisterWithScheme:(NSString*)aScheme;

/**
 * add Uri Register
 */
+(KCUriRegister*)addUriRegisterWithScheme:(NSString*)aScheme;


#pragma mark -
#pragma mark id<KCUriRegisterDelegate>

/**
 * return a Uri Register
 */
+(id<KCUriRegisterDelegate>)getUriRegister:(NSString*)aScheme;

/**
 * add uri register with KCUriRegisterDelegate, if use custom uri register ,you must realize KCUriRegisterDelegate interface
 */
+(BOOL)addUriRegister:(id<KCUriRegisterDelegate>)aUriRegisterDelegate;




@end
