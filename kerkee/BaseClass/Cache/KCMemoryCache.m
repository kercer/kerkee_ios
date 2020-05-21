//
//  KCMemoryCache.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCMemoryCache.h"

@interface KCMemoryCache ()
{
    NSMutableDictionary* m_dicCache;
    NSMutableArray* m_arrCacheKeys;
}

@end

@implementation KCMemoryCache

@synthesize maxCount;

-(id)init
{
    if (self = [super init])
    {
        m_dicCache = [[NSMutableDictionary alloc]init];
        m_arrCacheKeys = [[NSMutableArray alloc] init];
        self.maxCount = INT_MAX;
    }
    return self;
}


- (BOOL)hasCached:(NSString *)key
{
    return [m_dicCache objectForKey:key] ? YES : NO;
}
- (void)saveObject:(NSObject *)object forKey:(NSString *)key
{
    [m_dicCache setObject:object forKey:key];
}

- (void)saveKey:(NSString*)key
{
    if ([m_arrCacheKeys containsObject:key])
    {
        [m_arrCacheKeys removeObject:key];
    }
    [m_arrCacheKeys insertObject:key atIndex:0];
}

- (void)checkAndDelLastKey
{
    if (self.maxCount>0 && m_arrCacheKeys.count >= self.maxCount)
    {
        NSString* key = [m_arrCacheKeys lastObject];
        [self deleteCache:key];
    }
}

- (NSObject *)objectForKey:(NSString *)key
{
    return [m_dicCache objectForKey:key];
}

- (void)setCache:(NSString*)key Value:(id)value
{
    if (maxCount != INT_MAX)
    {
        [self checkAndDelLastKey];
        [self saveKey:key];
    }
    [self saveObject:value forKey:key];
}
- (id)getCache:(NSString*)key
{
    return [self objectForKey:key];
}
- (void)deleteCache:(NSString*)key
{
    if (key.length>0)
    {
        [m_dicCache removeObjectForKey:key];
        [m_arrCacheKeys removeObject:key];
    }
}

-(void)flushMemory
{
    [m_dicCache removeAllObjects];
    [m_arrCacheKeys removeAllObjects];
}

@end
