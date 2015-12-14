//
//  KCStack.m
//  kerkee
//
//  Created by zihong on 15/12/14.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCStack.h"

@interface KCStack ()
{
    NSMutableArray * m_stack;
}

@end

@implementation KCStack
@synthesize stack = m_stack;

- (NSUInteger)size
{
    return [m_stack count];
}

- (void)printStack
{
    if([m_stack count] == 0)
    {
        NSLog(@"Stack is empty; cannot print");
    }
    else
    {
        for(int i=0;i<[m_stack count];i++)
        {
            NSLog(@"Printing object at index %d", (int)[m_stack count] - 1 - i);
            NSLog(@"Stack object: %@",[m_stack objectAtIndex:([m_stack count]- 1 - i)]);
        }
    }
}

- (void)push:(id)object
{
    // Allocate memory for the array if the stack is empty
    if([m_stack count] == 0)
    {
        m_stack = [[NSMutableArray alloc] init];
    }
    
    [m_stack addObject:object];
}

- (void)clearStack
{
    [m_stack removeAllObjects];
}

- (id)pop
{
    id poppedObject = [m_stack objectAtIndex:([m_stack count]-1)];
    [m_stack removeLastObject];
    
    return poppedObject;
}

- (BOOL)isEmpty
{
    if([m_stack count] == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
