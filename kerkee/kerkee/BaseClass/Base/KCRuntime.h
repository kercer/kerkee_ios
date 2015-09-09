//
//  KCRuntime.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>


#pragma mark -

#pragma mark -

@interface KCCallFrame : NSObject
{
	NSUInteger			m_type;
	NSString *			m_process;
	NSUInteger			m_entry;
	NSUInteger			m_offset;
	NSString *			m_clazz;
	NSString *			m_method;
}


typedef enum
{
    ECallFrame_Type_Unknown,
    ECallFrame_Type_Objc,
    ECallFrame_Type_Native
}KCCallFrameType;

@property (nonatomic, assign) NSUInteger	type;
@property (nonatomic, retain) NSString *	process;
@property (nonatomic, assign) NSUInteger	entry;
@property (nonatomic, assign) NSUInteger	offset;
@property (nonatomic, retain) NSString *	clazz;
@property (nonatomic, retain) NSString *	method;

+ (id)parse:(NSString *)line;
+ (id)unknown;

@end

#pragma mark -

@interface KCRuntime : NSObject

+ (id)allocByClass:(Class)clazz;
+ (id)allocByClassName:(NSString *)clazzName;

+ (NSArray *)callstack:(NSUInteger)depth;
+ (NSArray *)callframes:(NSUInteger)depth;

//+ (void)printCallstack:(NSUInteger)depth;

+ (NSString*)getClassName:(id)obj;

+ (CGFloat) runTimeBlock:(void (^)(void))block;

@end
