//
//  NSObject+KCTicker.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface NSObject (KCTicker)

-(void)setTickerInterval:(NSTimeInterval)aInterval;
-(NSTimeInterval)getTickerInterval;

- (void)observeTick;
- (void)unobserveTick;
- (void)handleTick:(NSTimeInterval)elapsed;

@end
