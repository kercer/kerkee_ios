//
//  KCCache.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>


@protocol KCCache <NSObject>

//- (BOOL)hasCached:(NSString *)key;
//- (void)saveObject:(NSObject *)object forKey:(NSString *)key;
//- (NSObject *)objectForKey:(NSString *)key;
//- (void)setCache:(NSString*)key Value:(id)value;
//- (id)getCache:(NSString*)key;
//- (void)deleteCache:(NSString*)key;
//-(void)flushMemory;

@end

//这个基类后期用于做缓存池管理会用到
@interface KCCache : NSObject <KCCache>

@end
