//
//  KCLog.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCSingleton.h"
#import "KCBaseDefine.h"
#import "NSObject+KCObjectInfo.h"


#pragma mark -

#if __KC_LOG__


#undef	KC_PRINT
#define KC_PRINT( ... )		[[KCLogger sharedInstance] level:KCLogLevelNone format:__VA_ARGS__];

#undef	KC_INFO
#define KC_INFO( ... )		[[KCLogger sharedInstance] level:KCLogLevelInfo format:__VA_ARGS__];

#undef	KC_PERF
#define KC_PERF( ... )		[[KCLogger sharedInstance] level:KCLogLevelPerf format:__VA_ARGS__];

#undef	KC_WARN
#define KC_WARN( ... )		[[KCLogger sharedInstance] level:KCLogLevelWarn format:__VA_ARGS__];

#undef	KC_ERROR
#define KC_ERROR( ... )	[[KCLogger sharedInstance] level:KCLogLevelError format:__VA_ARGS__];

#undef	KCPrint
#define KCPrint( ... )	[[KCLogger sharedInstance] level:KCLogLevelNone format:__VA_ARGS__];

#undef	KC_DUMP_VAR
#define KC_DUMP_VAR( __obj )	KCPrint( [__obj description] );

#undef	KC_DUMP_OBJ
#define KC_DUMP_OBJ( __obj )	KCPrint( [__obj dump] );

#undef	KC_PRINT_CALLSTACK
#define KC_PRINT_CALLSTACK( __n )	 [KCLogger printCallstack:__n];

#undef KC_PRINT_RUNTIME_BEGIN
#define KC_PRINT_RUNTIME_BEGIN  [KCLogger printRuntime:^{

#undef KC_PRINT_RUNTIME_COMMIT
#define KC_PRINT_RUNTIME_COMMIT } prefix:[NSString stringWithFormat:(@"[Runtime] %s #%d\n"), __PRETTY_FUNCTION__, __LINE__]];


#else	// #if __KC_LOG__

#undef	KC_PRINT
#define KC_PRINT( ... )

#undef	KC_INFO
#define KC_INFO( ... )

#undef	KC_PERF
#define KC_PERF( ... )

#undef	KC_WARN
#define KC_WARN( ... )

#undef	KC_ERROR
#define KC_ERROR( ... )

#undef	KCPrint
#define KCPrint( ... )

#undef	KC_DUMP_VAR
#define KC_DUMP_VAR( __obj )

#undef	KC_DUMP_OBJ
#define KC_DUMP_OBJ( __obj )

#undef	KC_PRINT_CALLSTACK
#define KC_PRINT_CALLSTACK( __n )

#undef KC_PRINT_RUNTIME_BEGIN
#define KC_PRINT_RUNTIME_BEGIN

#undef KC_PRINT_RUNTIME_COMMIT
#define KC_PRINT_RUNTIME_COMMIT

#endif	// #if __KC_LOG__

#undef	KC_TODO
#define KC_TODO( desc, ... )

#pragma mark -


typedef enum
{
	KCLogLevelNone		= 0,
	KCLogLevelInfo		= 100,
	KCLogLevelPerf		= 200,
	KCLogLevelWarn		= 300,
	KCLogLevelError	= 400
} KCLogLevel;

#pragma mark -
@interface KCBacklog : NSObject
@property (nonatomic, retain) NSString *		module;
@property (nonatomic, assign) KCLogLevel		level;
@property (nonatomic, readonly) NSString *		levelString;
@property (nonatomic, retain) NSString *		file;
@property (nonatomic, assign) NSUInteger		line;
@property (nonatomic, retain) NSString *		func;
@property (nonatomic, retain) NSDate *			time;
@property (nonatomic, retain) NSString *		text;
@end

#pragma mark -

@interface KCLogger : NSObject

AS_SINGLETON( KCLogger );

@property (nonatomic, assign) BOOL				showLevel;
@property (nonatomic, assign) BOOL				showModule;
@property (nonatomic, assign) BOOL				enabled;
@property (nonatomic, retain) NSMutableArray *	backlogs;  //not implement
@property (nonatomic, assign) NSUInteger		indentTabs;

- (void)toggle;
- (void)enable;
- (void)disable;

- (void)indent;
- (void)indent:(NSUInteger)tabs;
- (void)unindent;
- (void)unindent:(NSUInteger)tabs;

- (void)level:(KCLogLevel)level format:(NSString *)format, ...;
- (void)level:(KCLogLevel)level format:(NSString *)format args:(va_list)args;

+ (void)printCallstack:(NSUInteger)depth;

//prefix string added before print run time
+ (void)printRuntime:(void (^)(void))block prefix:(NSString*)pre;

#pragma mark - file log
- (void)startFileLog;
- (void)stopFileLog;
- (NSString*)fileLogPath;
- (BOOL)deleteFileLog;

@end

#pragma mark -

#if __cplusplus
extern "C" {
#endif


#if __KC_LOG__Brief__
    #  define KCLog(fmt, ...) KCLogBrief(fmt, ##__VA_ARGS__)
#else
    #  define KCLog(fmt, ...) KCLoger(fmt, ##__VA_ARGS__)
#endif
    

#  define KCLoger(fmt, ...) KCLogBrief((@"%s #%d\n\t\t" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
	void KCLogBrief( NSString * format, ... );
	
#if __cplusplus
};
#endif


