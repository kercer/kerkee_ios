//
//  NSObject+KCSelector.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCSelector.h"

@implementation NSObject (Selector)


- (id)performSelectorWithArgs:(SEL)aSelector withObject:(id)first, ...
{
    id returnObj;
    
    va_list args;
    va_start(args, first);
    returnObj = [self performSelectorWithArgs:aSelector withObjectFormat:first arguments:args];
    va_end(args);
    
    return returnObj;
}


- (id)performSelectorWithArgs:(SEL)aSelector withObjectFormat:(id)format arguments:(va_list)argList
{
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    if (sig)
    {
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:self];
        [invo setSelector:aSelector];
        
        if(format)
        {
            [invo setArgument:&format atIndex:2];
            id arg;
            int argIndex = 3;
            while ((arg = va_arg(argList, id)))
            {
                [invo setArgument:&arg atIndex:argIndex];
                argIndex++;
            }
            
        }
        
        [invo retainArguments];
        [invo invoke];
        if (sig.methodReturnLength)
        {
            id anObject;
            [invo getReturnValue:&anObject];
            return anObject;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    return nil;
}



#pragma mark - Selectors
// Return an invocation based on a selector and variadic arguments
- (NSInvocation *) invocationWithSelector: (SEL) aSelector andArguments:(va_list) arguments
{
	if (![self respondsToSelector:aSelector]) return NULL;
	
	NSMethodSignature *ms = [self methodSignatureForSelector:aSelector];
	if (!ms) return NULL;
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	if (!inv) return NULL;
	
	[inv setTarget:self];
	[inv setSelector:aSelector];
	
	int argcount = 2;
	int totalArgs = (int)[ms numberOfArguments];
	
	while (argcount < totalArgs)
	{
		char *argtype = (char *)[ms getArgumentTypeAtIndex:argcount];
		if (strcmp(argtype, @encode(id)) == 0)
		{
			id argument = va_arg(arguments, id);
			[inv setArgument:&argument atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(char)) == 0) ||
				 (strcmp(argtype, @encode(unsigned char)) == 0) ||
				 (strcmp(argtype, @encode(short)) == 0) ||
				 (strcmp(argtype, @encode(unsigned short)) == 0) |
				 (strcmp(argtype, @encode(int)) == 0) ||
				 (strcmp(argtype, @encode(unsigned int)) == 0)
				 )
		{
			int i = va_arg(arguments, int);
			[inv setArgument:&i atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(long)) == 0) ||
				 (strcmp(argtype, @encode(unsigned long)) == 0)
				 )
		{
			long l = va_arg(arguments, long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(long long)) == 0) ||
				 (strcmp(argtype, @encode(unsigned long long)) == 0)
				 )
		{
			long long l = va_arg(arguments, long long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(float)) == 0) ||
				 (strcmp(argtype, @encode(double)) == 0)
				 )
		{
			double d = va_arg(arguments, double);
			[inv setArgument:&d atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(Class)) == 0)
		{
			Class c = va_arg(arguments, Class);
			[inv setArgument:&c atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(SEL)) == 0)
		{
			SEL s = va_arg(arguments, SEL);
			[inv setArgument:&s atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(char *)) == 0)
		{
			char *s = va_arg(arguments, char *);
			[inv setArgument:s atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(CGRect)) == 0)
        {
            CGRect arg = va_arg(arguments, CGRect);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGPoint)) == 0)
        {
            CGPoint arg = va_arg(arguments, CGPoint);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGSize)) == 0)
        {
            CGSize arg = va_arg(arguments, CGSize);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGAffineTransform)) == 0)
        {
            CGAffineTransform arg = va_arg(arguments, CGAffineTransform);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(NSRange)) == 0)
        {
            NSRange arg = va_arg(arguments, NSRange);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(UIOffset)) == 0)
        {
            UIOffset arg = va_arg(arguments, UIOffset);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(UIEdgeInsets)) == 0)
        {
            UIEdgeInsets arg = va_arg(arguments, UIEdgeInsets);
            [inv setArgument:&arg atIndex:argcount++];
        }
        else
        {
            // assume its a pointer and punt
            NSLog(@"Punting... %s", argtype);
            void *ptr = va_arg(arguments, void *);
            [inv setArgument:ptr atIndex:argcount++];
        }
	}
	
	if (argcount != totalArgs)
	{
		printf("Invocation argument count mismatch: %lu expected, %d sent\n", (unsigned long)[ms numberOfArguments], argcount);
		return NULL;
	}
	
	return inv;
}


// Return an invocation with the given arguments
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) aSelector, ...
{
	va_list arglist;
	va_start(arglist, aSelector);
	NSInvocation *inv = [self invocationWithSelector:aSelector andArguments:arglist];
	va_end(arglist);
	return inv;
}

// Peform the selector using va_list arguments
- (BOOL) performSelector: (SEL) aSelector withReturnValue: (void *) result andArguments: (va_list) arglist
{
	NSInvocation *inv = [self invocationWithSelector:aSelector andArguments:arglist];
	if (!inv) return NO;
    [inv retainArguments];
	[inv invoke];
    
    NSMethodSignature *sig = inv.methodSignature;
	if (result && sig.methodReturnLength)
        [inv getReturnValue:result];
	return YES;
}

// Perform a selector with an arbitrary number of arguments
- (BOOL) performSelector: (SEL) aSelector withReturnValueAndArguments: (void *) result, ...
{
	va_list arglist;
	va_start(arglist, result);
	NSInvocation *inv = [self invocationWithSelector:aSelector andArguments:arglist];
	if (!inv) return NO;
    [inv retainArguments];
	[inv invoke];
    NSMethodSignature *sig = inv.methodSignature;
	if (result && sig.methodReturnLength)
        [inv getReturnValue:result];
	va_end(arglist);
	return YES;
}


// Return a C-string with a selector's return type
// may extend this idea to return a class
- (const char *) returnTypeForSelector:(SEL)aSelector
{
	NSMethodSignature *ms = [self methodSignatureForSelector:aSelector];
	return [ms methodReturnType];
}


// Returning objects by performing selectors
- (id) performSelectorWithArgs:(SEL)aSelector, ...
{
	id result;
	va_list arglist;
	va_start(arglist, aSelector);
	[self performSelector:aSelector withReturnValue:&result andArguments:arglist];
	va_end(arglist);
	return result;
}


// Returning objects by performing selectors
- (id) performSelectorWithArgs:(SEL)aSelector arguments:(va_list)aArgList
{
    id result;
	[self performSelector:aSelector withReturnValue:&result andArguments:aArgList];
	return result;
}

// Returning objects by performing selectors
- (id) performSelectorSafetyWithArgs: (SEL)aSelector, ...
{
    id result;
    if ([self respondsToSelector:aSelector])
    {
        va_list args;
        va_start(args, aSelector);
        result = [self performSelectorWithArgs:aSelector arguments:args];
        va_end(args);
    }
    return result;
}

// Returning objects by performing selectors
- (id) performSelectorSafetyWithArgs:(SEL)aSelector arguments:(va_list)aArgList
{
    id result;
    if ([self respondsToSelector:aSelector])
    {
        result = [self performSelectorWithArgs:aSelector arguments:aArgList];
    }
    return result;

}

@end
