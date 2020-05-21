//
//  KCLog.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCLog.h"
#import "KCUtilFile.h"
#import "KCRuntime.h"



#pragma mark -

#pragma mark -

#undef	MAX_BACKLOG
#define MAX_BACKLOG	(50)

#pragma mark -

@implementation KCBacklog

@synthesize module = _module;
@synthesize level = _level;
@dynamic levelString;
@synthesize file = _file;
@synthesize line = _line;
@synthesize func = _func;
@synthesize time = _time;
@synthesize text = _text;

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.level = KCLogLevelNone;
		self.time = [NSDate date];
	}
	return self;
}

- (void)dealloc
{
	self.module = nil;
	self.file = nil;
	self.func = nil;
	self.time = nil;
	self.text = nil;
    
    KCDealloc(super);
}

- (NSString *)levelString
{
	if ( KCLogLevelInfo == self.level )
	{
		return @"INFO";
	}
	else if ( KCLogLevelPerf == self.level )
	{
		return @"PERF";
	}
	else if ( KCLogLevelWarn == self.level )
	{
		return @"WARN";
	}
	else if ( KCLogLevelError == self.level )
	{
		return @"ERROR";
	}
    
	return @"SYSTEM";
}

@end

#pragma mark -

@interface KCLogger()
{
}


@end

#pragma mark -

@implementation KCLogger

DEF_SINGLETON( KCLogger );

@synthesize showLevel;
@synthesize showModule;

@synthesize enabled ;
@synthesize backlogs ;
@synthesize indentTabs ;


- (id)init
{
	self = [super init];
	if ( self )
	{
		self.showLevel = YES;
		self.showModule = NO;
		
		self.enabled = YES;
		self.backlogs = [NSMutableArray array];
		self.indentTabs = 0;
        
        [self startFileLog];
	}
	return self;
}

- (void)dealloc
{
    [self stopFileLog];
    
	self.backlogs = nil;
    KCDealloc(super);
}


- (void)toggle
{
	self.enabled = self.enabled ? NO : YES;
}

- (void)enable
{
	self.enabled = YES;
}

- (void)disable
{
	self.enabled = NO;
}

- (void)indent
{
	self.indentTabs += 1;
}

- (void)indent:(NSUInteger)tabs
{
	self.indentTabs += tabs;
}

- (void)unindent
{
	if ( self.indentTabs > 0 )
	{
		self.indentTabs -= 1;
	}
}

- (void)unindent:(NSUInteger)tabs
{
	if ( self.indentTabs < tabs )
	{
		self.indentTabs = 0;
	}
	else
	{
		self.indentTabs -= tabs;
	}
}


- (void)level:(KCLogLevel)level format:(NSString *)format, ...
{
#if (__ON__ == __KC_LOG__)
	
	if ( nil == format || NO == [format isKindOfClass:[NSString class]] )
		return;
    
	va_list args;
	va_start( args, format );
    
	[self level:level format:format args:args];
    
	va_end( args );
    
#endif	// #if (__ON__ == __KC_LOG__)
}


- (void)level:(KCLogLevel)level format:(NSString *)format args:(va_list)args
{
#if (__ON__ == __KC_LOG__)
	
	if ( NO == self.enabled )
		return;
	
    // formatting
    
	NSMutableString * text = [NSMutableString string];
	NSMutableString * tabs = nil;
	
	if ( self.indentTabs > 0 )
	{
		tabs = [NSMutableString string];
		
		for ( int i = 0; i < self.indentTabs; ++i )
		{
			[tabs appendString:@"\t"];
		}
	}
	
	NSString * module = nil;
    
	if ( self.showLevel || self.showModule )
	{
		NSMutableString * temp = [NSMutableString string];
        
		if ( self.showLevel )
		{
			if ( KCLogLevelInfo == level )
			{
				[temp appendString:@"[INFO]"];
			}
			else if ( KCLogLevelPerf == level )
			{
				[temp appendString:@"[PERF]"];
			}
			else if ( KCLogLevelWarn == level )
			{
				[temp appendString:@"[WARN]"];
			}
			else if ( KCLogLevelError == level )
			{
				[temp appendString:@"[ERROR]"];
			}
		}
        
		if ( self.showModule )
		{
			if ( module && module.length )
			{
				[temp appendFormat:@" [%@]", module];
			}
		}
		
		if ( temp.length )
		{
			NSString * temp2 = [temp stringByPaddingToLength:((temp.length / 8) + 1) * 8 withString:@" " startingAtIndex:0];
			[text appendString:temp2];
		}
	}
    
	if ( tabs && tabs.length )
	{
		[text appendString:tabs];
	}
    
	NSString * content = [[NSString alloc] initWithFormat:(NSString *)format arguments:args];
    KCAutorelease(content);
	if ( content && content.length )
	{
		[text appendString:content];
	}
	
//	if ( [text rangeOfString:@"\n"].length )
//	{
//		[text replaceOccurrencesOfString:@"\n"
//							  withString:[NSString stringWithFormat:@"%@", tabs ? tabs : @"\t\t"]
//								 options:NSCaseInsensitiveSearch
//								   range:NSMakeRange( 0, text.length )];
//	}
	
    [text appendString:@"\n"];
    
	// print to console
    @synchronized(self)
    {
        fprintf( stderr, [text UTF8String], NULL );
//        fprintf( stderr, "\n", NULL );
        fflush(stderr);
    }
//    printf("%s\n",[text UTF8String]);
#endif	// #if (__ON__ == __KC_LOG__)
}


+ (void)printCallstack:(NSUInteger)depth
{
	NSArray * callstack = [KCRuntime callstack:depth];
	if ( callstack && callstack.count )
	{
		KC_DUMP_VAR(callstack);
	}
}

+ (void)printRuntime:(void (^)(void))block prefix:(NSString*)pre
{
#if (__ON__ == __KC_LOG__)
    double time = [KCRuntime runTimeBlock:block];
    NSString* preTemp = pre ? pre : @"";
    KCPrint(@"%@Runtime is:%f s",preTemp, time);
#endif
}

#pragma mark - file log

- (void)startFileLog
{
#if (__KC_LOG__FILE__)
    freopen([[self fileLogPath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    freopen([[self fileLogPath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
}

- (void)stopFileLog
{
#if (__KC_LOG__FILE__)
    fflush(stderr);
    dup2(dup(STDERR_FILENO), STDERR_FILENO);
    close(dup(STDERR_FILENO));
#endif
}

- (NSString*)fileLogPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    return logPath;
}

- (BOOL)deleteFileLog
{
#if (__KC_LOG__FILE__)
    [self stopFileLog];
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self fileLogPath] error:nil];
    [self startFileLog];
    return success;
#else
    return NO;
#endif
}


@end

#if __cplusplus
extern "C"
#endif	// #if __cplusplus
void KCLogBrief( NSString * format, ... )
{
#if (__ON__ == __KC_LOG__)
    
	if ( nil == format || NO == [format isKindOfClass:[NSString class]] )
		return;
	

        va_list args;
        va_start( args, format );
    
        [[KCLogger sharedInstance] level:KCLogLevelInfo format:format args:args];
    
        va_end( args );

    
#endif	// #if (__ON__ == __KC_LOG__)
}

