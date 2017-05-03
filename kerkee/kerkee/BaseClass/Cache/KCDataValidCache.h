//
//  KCDataValidCache.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCCache.h"

//暂不继承或组合KCFileCache,可更灵活扩展
@interface KCDataValidCache : KCCache

+ (KCDataValidCache*) defaultCache;

-(id)initWithCacheUser:(NSString*)user;

-(void)setCacheDirectory:(NSString*)dirPath;
-(void)setCacheDirectory:(NSString*)dirPath cacheUser:(NSString*)user;

- (void)setCache:(NSString*)key Value:(id)value Seconds:(double)seconds;
- (void)setCacheAuto:(NSString*)key Value:(id)value Seconds:(double)seconds;
- (void)setCache:(NSString*)key Value:(id)value Seconds:(double)seconds ValueCacheInFile:(BOOL)cacheInFile;
- (id)getCache:(NSString*)key;

-(void)deleteCache:(NSString*)key;
-(void)deleteUserCache;
-(void)changeUserCache:(NSString*)user;

-(void)cleanOutTimeCache;


@end
