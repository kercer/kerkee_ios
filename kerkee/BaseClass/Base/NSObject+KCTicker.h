//
//  NSObject+KCTicker.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface NSObject (KCTicker)

-(void)kc_setTickerInterval:(NSTimeInterval)aInterval;
-(NSTimeInterval)kc_getTickerInterval;

- (void)kc_observeTick;
- (void)kc_unobserveTick;
- (void)kc_handleTick:(NSTimeInterval)elapsed;

@end
