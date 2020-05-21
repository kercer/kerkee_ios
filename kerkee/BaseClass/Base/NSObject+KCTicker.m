//
//  NSObject+KCTicker.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCTicker.h"
#import "KCSingleton.h"
#import "KCBaseDefine.h"
#import <objc/runtime.h>

#pragma mark -

@interface KCTicker : NSObject
{
	NSTimer *			m_timer;
	NSMutableArray *	m_receives;
}

@property (nonatomic, readonly)	NSTimer *			timer;

AS_SINGLETON( KCTicker )

- (void)addReceive:(NSObject *)obj;
- (void)removeReceive:(NSObject *)obj;

- (void)performTick;

@end




#pragma mark -

@implementation NSObject(KCTicker)

#define Key_Interval @"com.kercer.KCTicker.Interval"
#define Key_LastTick @"com.kercer.KCTicker.LastTick"

-(void)kc_setTickerInterval:(NSTimeInterval)aInterval
{
    objc_setAssociatedObject(self, (__bridge const void *)Key_Interval, [NSNumber numberWithDouble:aInterval], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSTimeInterval)kc_getTickerInterval
{
    NSNumber *interval = objc_getAssociatedObject(self, (__bridge const void *)Key_Interval);
    return [interval doubleValue];
}


-(void)kc_setLastTick:(NSTimeInterval)aInterval
{
    objc_setAssociatedObject(self, (__bridge const void *)Key_LastTick, [NSNumber numberWithDouble:aInterval], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSTimeInterval)kc_getLastTick
{
    NSNumber *interval = objc_getAssociatedObject(self, (__bridge const void *)Key_LastTick);
    return [interval doubleValue];
}

- (void)kc_observeTick
{
    NSTimeInterval lastTick = [NSDate timeIntervalSinceReferenceDate];
    [self kc_setLastTick:lastTick];
    
	[[KCTicker sharedInstance] addReceive:self];
}

- (void)kc_unobserveTick
{
	[[KCTicker sharedInstance] removeReceive:self];
}

- (void)kc_handleTick:(NSTimeInterval)elapsed
{
}


- (void)kc_handleTickWithNumber:(NSNumber*)elapsed
{
    [self kc_handleTick:[elapsed doubleValue]];
}

@end



#pragma mark -
@implementation KCTicker

@synthesize timer = m_timer;

DEF_SINGLETON( KCTicker )

- (id)init
{
	self = [super init];
	if ( self )
	{
		m_receives = [[NSMutableArray alloc] init];
	}
    
	return self;
}

- (void)addReceive:(NSObject *)obj
{
	if ( NO == [m_receives containsObject:obj] )
	{
		[m_receives addObject:obj];
        
		if ( nil == m_timer )
		{
            NSDate* fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            KCAutorelease(fireDate);
            m_timer = [[NSTimer alloc] initWithFireDate:fireDate interval:0.1 target:self selector:@selector(performTick) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:m_timer forMode:NSRunLoopCommonModes];
		}
	}
}

- (void)removeReceive:(NSObject *)obj
{
	[m_receives removeObject:obj];
    
	if ( 0 == m_receives.count )
	{
		[m_timer invalidate];
		m_timer = nil;
	}
}

- (void)performTick
{
	NSTimeInterval tick = [NSDate timeIntervalSinceReferenceDate];
    
	for ( NSObject * obj in m_receives )
	{
		if ( [obj respondsToSelector:@selector(kc_handleTick:)] )
		{
            NSTimeInterval lastTick = [obj kc_getLastTick];
            NSTimeInterval curInterval = tick -lastTick;
            NSTimeInterval interval = [obj kc_getTickerInterval];
            
            if(curInterval >= interval)
            {
                [obj performSelectorOnMainThread:@selector(kc_handleTickWithNumber:) withObject:[NSNumber numberWithDouble:curInterval] waitUntilDone:NO];
                [obj kc_setLastTick:tick];
            }
			
		}
	}
}

- (void)dealloc
{
	[m_timer invalidate];
	m_timer = nil;
    
	[m_receives removeAllObjects];
    KCRelease(m_receives);
    
	KCDealloc(super);
}

@end


