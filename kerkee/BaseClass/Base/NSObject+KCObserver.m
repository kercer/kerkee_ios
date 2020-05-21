//
//  NSObject+KCObserver.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCObserver.h"
#import "NSObject+KCSelector.h"
#import <objc/runtime.h>
#import "KCBaseDefine.h"

@implementation NSObject (KCObserver)

#define Key_Delegates @"com.kercer.Delegates"

-(void)setDelegates:(NSArray*)arrDelegates
{
    objc_setAssociatedObject(self, (__bridge const void *)Key_Delegates, arrDelegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray*)getDelegates
{
    NSMutableArray *arrDelegates = objc_getAssociatedObject(self, (__bridge const void *)Key_Delegates);
    
    return arrDelegates;
}

-(BOOL)registerDelegate:(id)delegate
{
    if(delegate == nil) return NO;
    
    NSMutableArray* arrDelegates = [self getDelegates];
    
    if(arrDelegates == nil)
    {
        arrDelegates = [[NSMutableArray alloc]init];
        [self setDelegates:arrDelegates];
    }
    
    if (![arrDelegates containsObject:delegate])
    {
        [arrDelegates addObject:delegate];
        return YES;
    }
    
    return NO;
}

-(void)removeDelegate:(id)delegate
{
    if(delegate==nil) return;
    
    NSMutableArray* arrDelegates = [self getDelegates];
    
    if ([arrDelegates containsObject:delegate])
    {
        [arrDelegates removeObject:delegate];
        if(arrDelegates.count == 0)
        {
            KCRelease(arrDelegates);
            [self setDelegates:nil];
        }
    }
}


- (void)performDelegates:(SEL)aSelector withObject:(id)first, ...
{
    va_list args;
    va_start(args, first);
    [self performDelegates:aSelector withObjectFormat:first arguments:args];
    va_end(args);
    
    return;
}

- (void)performDelegates:(SEL)aSelector withObjectFormat:(id)format arguments:(va_list)argList
{
    NSMutableArray* arrDelegates = [self getDelegates];
    if (arrDelegates)
    {
        for (id delegate in arrDelegates)
        {
            if (delegate && [delegate respondsToSelector:aSelector])
            {
                [delegate performSelectorWithArgs:aSelector, format, argList, nil];
            }
        }
    }
}


// arg list can support internal types
- (void) performDelegates:(SEL)aSelector, ...
{
    va_list args;
    va_start(args, aSelector);
    [self performDelegates:aSelector arguments:args];
    va_end(args);

}
- (void) performDelegates:(SEL)aSelector arguments:(va_list)argList
{
    NSMutableArray* arrDelegates = [self getDelegates];
    if (arrDelegates)
    {
        for (id delegate in arrDelegates)
        {
            if (delegate && [delegate respondsToSelector:aSelector])
            {
                [delegate performSelectorWithArgs:aSelector arguments:argList];
            }
        }
    }

}

@end
