//
//  KCTaskQueue.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCTaskQueue.h"
#import "KCBaseDefine.h"

#pragma mark -

@implementation KCTaskQueue

DEF_SINGLETON( KCTaskQueue )

- (id)init
{    
    return [self initWithName:nil Att:DISPATCH_QUEUE_SERIAL];
}


-(id)initWithName:(NSString*)aName
{
    return [self initWithName:aName Att:DISPATCH_QUEUE_SERIAL];
}

-(id)initWithName:(NSString*)aName Att:(dispatch_queue_attr_t)aAtt
{
    self = [super init];
	if ( self )
	{
        const char* pchName = [aName cStringUsingEncoding:NSASCIIStringEncoding];
        if(!aName || 0 == aName.length) pchName = "com.kercer.taskQueue";
		m_foreQueue = dispatch_get_main_queue();
		m_backQueue = dispatch_queue_create(pchName, aAtt ); //并行：DISPATCH_QUEUE_CONCURRENT 串行DISPATCH_QUEUE_SERIAL
	}
    
	return self;
}

- (dispatch_queue_t)foreQueue
{
	return m_foreQueue;
}

- (dispatch_queue_t)backQueue
{
	return m_backQueue;
}

- (void)dealloc
{
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(m_backQueue);
    #endif
    
	KCDealloc(super);
}

- (void)foreground:(dispatch_block_t)aBlock
{
	dispatch_async( m_foreQueue, aBlock );
}

- (void)background:(dispatch_block_t)aBlock
{
	dispatch_async( m_backQueue, aBlock );
}

- (void)foregroundWithDelay:(dispatch_time_t)ms block:(dispatch_block_t)block
{
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, ms * USEC_PER_SEC);
	dispatch_after( time, m_foreQueue, block );
}

- (void)backgroundWithDelay:(dispatch_time_t)ms block:(dispatch_block_t)block
{
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, ms * USEC_PER_SEC);
	dispatch_after( time, m_backQueue, block );
}

@end


