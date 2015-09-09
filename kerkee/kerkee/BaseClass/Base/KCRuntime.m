//
//  KCRuntime.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCRuntime.h"
#import "KCBaseDefine.h"
#import <objc/runtime.h>

#import <mach/mach_time.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <sys/errno.h>
#include <math.h>
#include <limits.h>
#include <objc/runtime.h>
#include <execinfo.h>


#define MAX_CALLSTACK_DEPTH	(64)

#pragma mark -

@interface KCCallFrame(Private)
+ (NSUInteger)hex:(NSString *)text;
+ (id)parseFormat1:(NSString *)line;
+ (id)parseFormat2:(NSString *)line;
@end

#pragma mark -

@implementation KCCallFrame

@synthesize type = m_type;
@synthesize process = m_process;
@synthesize entry = m_entry;
@synthesize offset = m_offset;
@synthesize clazz = m_clazz;
@synthesize method = m_method;

- (NSString *)description
{
	if ( ECallFrame_Type_Objc == m_type )
	{
		return [NSString stringWithFormat:@"[O] %@(0x%08lx + %lu) -> [%@ %@]", m_process, (unsigned long)m_entry, (unsigned long)m_offset, m_clazz, m_method];
	}
	else if ( ECallFrame_Type_Native == m_type )
	{
		return [NSString stringWithFormat:@"[C] %@(0x%08lx + %lu) -> %@", m_process, (unsigned long)m_entry, (unsigned long)m_offset, m_method];
	}
	else
	{
		return [NSString stringWithFormat:@"[X] <unknown>(0x%08lx + %lu)", (unsigned long)m_entry, (unsigned long)m_offset];
	}
}

+ (NSUInteger)hex:(NSString *)text
{
	unsigned long long number = 0;
	[[NSScanner scannerWithString:text] scanHexLongLong:&number];
	return (NSUInteger)number;
}

+ (id)parseFormat1:(NSString *)line
{
    //	example: peeper  0x00001eca -[xxAppDelegate application:didFinishLaunchingWithOptions:] + 106
	NSError * error = NULL;
	NSString * expr = @"^[0-9]*\\s*([a-z0-9_]+)\\s+(0x[0-9a-f]+)\\s+-\\[([a-z0-9_]+)\\s+([a-z0-9_:]+)]\\s+\\+\\s+([0-9]+)$";
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expr options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult * result = [regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
	if ( result && (regex.numberOfCaptureGroups + 1) == result.numberOfRanges )
	{
		KCCallFrame * frame = [[KCCallFrame alloc] init];
        KCAutorelease(frame);
		frame.type = ECallFrame_Type_Objc;
		frame.process = [line substringWithRange:[result rangeAtIndex:1]];
		frame.entry = [KCCallFrame hex:[line substringWithRange:[result rangeAtIndex:2]]];
		frame.clazz = [line substringWithRange:[result rangeAtIndex:3]];
		frame.method = [line substringWithRange:[result rangeAtIndex:4]];
		frame.offset = [[line substringWithRange:[result rangeAtIndex:5]] intValue];
		return frame;
	}
    
	return nil;
}

+ (id)parseFormat2:(NSString *)line
{
    //	example: UIKit 0x0105f42e UIApplicationMain + 1160
	NSError * error = NULL;
	NSString * expr = @"^[0-9]*\\s*([a-z0-9_]+)\\s+(0x[0-9a-f]+)\\s+([a-z0-9_]+)\\s+\\+\\s+([0-9]+)$";
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expr options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult * result = [regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
	if ( result && (regex.numberOfCaptureGroups + 1) == result.numberOfRanges )
	{
		KCCallFrame * frame = [[KCCallFrame alloc] init];
        KCAutorelease(frame);
		frame.type = ECallFrame_Type_Native;
		frame.process = [line substringWithRange:[result rangeAtIndex:1]];
		frame.entry = [self hex:[line substringWithRange:[result rangeAtIndex:2]]];
		frame.clazz = nil;
		frame.method = [line substringWithRange:[result rangeAtIndex:3]];
		frame.offset = [[line substringWithRange:[result rangeAtIndex:4]] intValue];
		return frame;
	}
    
	return nil;
}

+ (id)unknown
{
	KCCallFrame * frame = [[KCCallFrame alloc] init];
    KCAutorelease(frame);
	frame.type = ECallFrame_Type_Unknown;
	return frame;
}

+ (id)parse:(NSString *)line
{
	if ( 0 == [line length] )
		return nil;
    
	id frame1 = [KCCallFrame parseFormat1:line];
	if ( frame1 )
		return frame1;
    
	id frame2 = [KCCallFrame parseFormat2:line];
	if ( frame2 )
		return frame2;
    
	return [KCCallFrame unknown];
}

- (void)dealloc
{
    KCRelease(m_process);
    KCRelease(m_clazz);
    KCRelease(m_method);
    KCDealloc(super);
}

@end

#pragma mark -

@implementation KCRuntime

+ (id)allocByClass:(Class)clazz
{
	if ( nil == clazz )
		return nil;
    
	return [clazz alloc];
}

+ (id)allocByClassName:(NSString *)clazzName
{
	if ( nil == clazzName || 0 == [clazzName length] )
		return nil;
    
	Class clazz = NSClassFromString( clazzName );
	if ( nil == clazz )
		return nil;
    
	return [clazz alloc];
}

+ (NSArray *)callstack:(NSUInteger)depth
{
	NSMutableArray * array = [[NSMutableArray alloc] init];
    KCAutorelease(array);
    
	void * stacks[MAX_CALLSTACK_DEPTH] = { 0 };
    
	depth = backtrace( stacks, (depth > MAX_CALLSTACK_DEPTH) ? MAX_CALLSTACK_DEPTH : (int)depth );
	if ( depth > 1 )
	{
		char ** symbols = backtrace_symbols( stacks, (int)depth );
		if ( symbols )
		{
			for ( int i = 0; i < (depth - 1); ++i )
			{
				NSString * symbol = [NSString stringWithUTF8String:(const char *)symbols[1 + i]];
				if ( 0 == [symbol length] )
					continue;
                
				NSRange range1 = [symbol rangeOfString:@"["];
				NSRange range2 = [symbol rangeOfString:@"]"];
                
				if ( range1.length > 0 && range2.length > 0 )
				{
					NSRange range3;
					range3.location = range1.location;
					range3.length = range2.location + range2.length - range1.location;
					[array addObject:[symbol substringWithRange:range3]];
				}
				else
				{
					[array addObject:symbol];
				}
			}
            
			free( symbols );
		}
	}
    
	return array;
}

+ (NSArray *)callframes:(NSUInteger)depth
{
	NSMutableArray * array = [[NSMutableArray alloc] init];
    KCAutorelease(array);
    
	void * stacks[MAX_CALLSTACK_DEPTH] = { 0 };
    
	depth = backtrace( stacks, (depth > MAX_CALLSTACK_DEPTH) ? MAX_CALLSTACK_DEPTH : (int)depth );
	if ( depth > 1 )
	{
		char ** symbols = backtrace_symbols( stacks, (int)depth );
		if ( symbols )
		{
			for ( int i = 0; i < (depth - 1); ++i )
			{
				NSString * line = [NSString stringWithUTF8String:(const char *)symbols[1 + i]];
				if ( 0 == [line length] )
					continue;
                
				KCCallFrame * frame = [KCCallFrame parse:line];
				if ( nil == frame )
					continue;
                
				[array addObject:frame];
			}
            
			free( symbols );
		}
	}
    
	return array;
}

//+ (void)printCallstack:(NSUInteger)depth
//{
//	NSArray * callstack = [self callstack:depth];
//	if ( callstack && callstack.count )
//	{
//		KC_DUMP_VAR(callstack);
//	}
//}


+ (NSString*)getClassName:(id)obj
{
    return [NSString stringWithUTF8String:object_getClassName(obj)];
}


+ (CGFloat) runTimeBlock:(void (^)(void))block
{
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
    
}

@end
