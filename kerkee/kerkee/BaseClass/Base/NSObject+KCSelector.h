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

- (id)performSelectorWithArgs:(SEL)aSelector withObject:(id)first, ... NS_REQUIRES_NIL_TERMINATION __attribute__((deprecated("use 'performSelectorWithArgs:' in deepContent instead")));
- (id)performSelectorWithArgs:(SEL)aSelector withObjectFormat:(id)format arguments:(va_list)argList __attribute__((deprecated("use 'performSelectorWithArgs:' in deepContent instead")));

// Request return value from performing selector
// arg list can support internal types
- (id) performSelectorWithArgs:(SEL)aSelector, ...;
- (id) performSelectorWithArgs:(SEL)aSelector arguments:(va_list)aArgList;

- (id) performSelectorSafetyWithArgs:(SEL)aSelector, ...;
- (id) performSelectorSafetyWithArgs:(SEL)aSelector arguments:(va_list)aArgList;


#pragma mark --
// Selector Utilities
// Return an invocation based on a selector and variadic arguments
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) aSelector,...;
- (NSInvocation *) invocationWithSelector: (SEL) aSelector andArguments:(va_list) arguments;
- (BOOL) performSelector: (SEL) aSelector withReturnValueAndArguments: (void *) result, ...;
- (BOOL) performSelector: (SEL) aSelector withReturnValue: (void *) result andArguments: (va_list) arglist;
- (const char *) returnTypeForSelector:(SEL)aSelector;



@end
