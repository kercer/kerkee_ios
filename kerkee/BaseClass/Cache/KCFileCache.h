//
//  KCFileCache.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCCache.h"

@interface KCFileCache : KCCache
{
    NSString* m_strCacheDirectory;
    NSString* m_strCacheUser;
}

-(id)initWithCacheUser:(NSString*)user;
-(void)setCacheDirectory:(NSString*)dirPath;
-(void)setCacheDirectory:(NSString*)dirPath cacheUser:(NSString*)user;

- (NSString*)cacheDirectory;
- (NSString*)cacheFileNameWithKey:(NSString*)key;
- (NSData *)serialize:(NSObject *)obj;
- (NSObject *)unserialize:(NSData *)data;

- (void)setCache:(NSString*)key Value:(id)value;
- (id)getCache:(NSString*)key;

@end
