//
//  KCMemoryCache.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCCache.h"

@interface KCMemoryCache : KCCache

@property(nonatomic, assign) NSInteger maxCount;

- (void)setCache:(NSString*)key Value:(id)value;
- (id)getCache:(NSString*)key;
- (void)flushMemory;

@end
