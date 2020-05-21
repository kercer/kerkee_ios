//
//  NSObject+KCObserver.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface NSObject (KCObserver)

-(BOOL)registerDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;

- (void)performDelegates:(SEL)aSelector withObject:(id)first, ... NS_REQUIRES_NIL_TERMINATION;
- (void)performDelegates:(SEL)aSelector withObjectFormat:(id)format arguments:(va_list)argList;

// arg list can support internal types
- (void) performDelegates: (SEL)aSelector, ...;
- (void) performDelegates:(SEL)aSelector arguments:(va_list)argList;

@end
