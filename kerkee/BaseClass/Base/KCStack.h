//
//  KCStack.h
//  kerkee
//
//  Created by zihong on 15/12/14.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCStack : NSObject

@property (nonatomic, retain) NSMutableArray *stack;    // The NSMutableArray that acts as the stack

- (NSUInteger)size;                        // Get size of stack
- (void)printStack;                 // Print stack to logs
- (void)push:(id)object;     // Push object into stack
- (void)clearStack;                 // Clears the stack of all objects
- (id)pop;                          // Pop object off stack
- (BOOL)isEmpty;                    // Check if stack is empty


@end
