//
//  NSObject+KCSelector.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <CoreGraphics/CGAffineTransform.h>

@interface NSObject (KCSelector)

- (id)kc_performSelectorWithArgs:(SEL)aSelector withObject:(id)first, ... NS_REQUIRES_NIL_TERMINATION __attribute__((deprecated("use 'performSelectorWithArgs:' in deepContent instead")));
- (id)kc_performSelectorWithArgs:(SEL)aSelector withObjectFormat:(id)format arguments:(va_list)argList __attribute__((deprecated("use 'performSelectorWithArgs:' in deepContent instead")));

// Request return value from performing selector
// arg list can support internal types
- (id) kc_performSelectorWithArgs:(SEL)aSelector, ...;
- (id) kc_performSelectorWithArgs:(SEL)aSelector arguments:(va_list)aArgList;

- (id) kc_performSelectorSafetyWithArgs:(SEL)aSelector, ...;
- (id) kc_performSelectorSafetyWithArgs:(SEL)aSelector arguments:(va_list)aArgList;


#pragma mark --
// Selector Utilities
// Return an invocation based on a selector and variadic arguments
- (NSInvocation *) kc_invocationWithSelectorAndArguments: (SEL) aSelector,...;
- (NSInvocation *) kc_invocationWithSelector: (SEL) aSelector andArguments:(va_list) arguments;
- (BOOL) kc_performSelector: (SEL) aSelector withReturnValueAndArguments: (void *) result, ...;
- (BOOL) kc_performSelector: (SEL) aSelector withReturnValue: (void *) result andArguments: (va_list) arglist;
- (const char *) kc_returnTypeForSelector:(SEL)aSelector;



@end
