//
//  KCDataValidCache.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCDataValidCache.h"
#import "KCBaseDefine.h"
#include <objc/runtime.h>
#import "NSString+KCExtension.h"

#define KFile @"isFile" //fileName为key值
#define KValue @"value"
#define KExpires @"expires"

#define CONFIG @"DataCache.cfg"

@interface KCDataValidCache ()
{
    NSMutableDictionary* m_dicCache;
    
    NSString* m_strCacheDirectory;
    NSString* m_strCacheUser; 
}

@end


@implementation KCDataValidCache

static KCDataValidCache* instance = nil;

-(id)init
{
    if (self = [super init])
    {
        [self loadCfg];
    }
    return self;
}

-(id)initWithCacheUser:(NSString*)user
{
    if (self = [super init])
    {
        m_strCacheUser = user;
        KCRetain(m_strCacheUser);
        [self loadCfg];
    }
    return self;
}

-(void)dealloc
{
    KCDealloc(super);
}


+ (KCDataValidCache*) defaultCache
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[self alloc] init] ;
            KCAutorelease(instance);
        }
    }
    return instance;
}

//+(id) allocWithZone:(NSZone *)zone
//{
//    @synchronized(self)
//    {
//        if (instance == nil)
//        {
//            instance = [super allocWithZone:zone];
//            return instance;
//        }
//    }
//    return nil;
//    
//}

- (NSString*)cacheDirectory
{
	if (m_strCacheDirectory == nil)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* libraryDirectory = [paths objectAtIndex:0];
        
		m_strCacheDirectory = [[libraryDirectory
                            stringByAppendingPathComponent:@"Private Documents"]
                           stringByAppendingPathComponent:@"Data Cache"];
        
        if ( m_strCacheUser && [m_strCacheUser length] )
        {
//            DLog(@"%@", cacheDirectory);
            m_strCacheDirectory = [m_strCacheDirectory stringByAppendingFormat:@"/%@/", m_strCacheUser];
//            DLog(@"%@", cacheDirectory);
        }
        
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:m_strCacheDirectory])
		{
			NSError* error = nil;
			if (![fileManager createDirectoryAtPath:m_strCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error])
				NSLog(@"Error creating directory: %@", [error description]);
		}
	}
	return m_strCacheDirectory;
}

-(void)setCacheDirectory:(NSString*)dirPath
{
    [self setCacheDirectory:dirPath cacheUser:nil];
}

-(void)setCacheDirectory:(NSString*)dirPath cacheUser:(NSString*)user
{
    if(dirPath==nil || dirPath.length == 0) return;
    
    m_strCacheDirectory = dirPath;
    KCRetain(m_strCacheDirectory);
    if ( user && [user length] )
    {
        m_strCacheUser = user;
        KCRetain(m_strCacheUser);
        m_strCacheDirectory = [m_strCacheDirectory stringByAppendingFormat:@"/%@/", user];
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:m_strCacheDirectory])
    {
        NSError* error = nil;
        if (![fileManager createDirectoryAtPath:m_strCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"Error creating directory: %@", [error description]);
    }

}


- (NSString*)cacheFileNameWithKey:(NSString*)key
{
    NSString* keyTemp = [key kc_MD5];
    NSString* keyHash = [NSString stringWithFormat:@"%lu", (unsigned long)[keyTemp hash]];
    NSString* path = nil;
    path = [[self cacheDirectory] stringByAppendingPathComponent:keyHash];
//    DLog(@"dataCache Path:%@", path);
    return path;
}

-(NSString *)getCfgPath
{
    return [[self cacheDirectory] stringByAppendingPathComponent:CONFIG];
}

-(void)updateCfg
{
//    [m_CacheDic writeToFile:[self getCfgPath] atomically:NO];
    NSData* data = [self serialize:m_dicCache];
    if(data)
    {
        [data writeToFile:[self getCfgPath] options:NSDataWritingAtomic error:nil];
    }
    
}

-(NSDictionary*)loadCfg
{
    NSData* data = [NSData dataWithContentsOfFile:[self getCfgPath]];
    if ( data )
	{
		 NSDictionary* dic = (NSDictionary*)[self unserialize:data];
        m_dicCache = [NSMutableDictionary dictionaryWithDictionary:dic];
	}
    
//    m_CacheDic = [[NSMutableDictionary alloc]initWithContentsOfFile:[self getCfgPath]];
    if (m_dicCache == nil)
    {
        m_dicCache = [[NSMutableDictionary alloc]init];
    }
    return m_dicCache;
}


- (NSData *)dataForKey:(NSString *)key
{
    
	NSString * filePath = [self cacheFileNameWithKey:key];
	return [NSData dataWithContentsOfFile:filePath];
}

-(void)saveData:(NSData *)data forKey:(NSString*)key
{
    if ( nil == data )
	{
		[self deleteCache:key];
	}
	else
	{
		[data writeToFile:[self cacheFileNameWithKey:key] options:NSDataWritingAtomic error:nil];
	}
}


- (NSData *)serialize:(NSObject *)obj
{
    return [NSKeyedArchiver archivedDataWithRootObject:obj];
}

- (NSObject *)unserialize:(NSData *)data
{
    @try
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    @finally
    {
    }
    
}


- (NSObject *)objectForKey:(NSString *)key
{
	NSData * data = [self dataForKey:key];
	if ( data )
	{
		return [self unserialize:data];
	}
    
	return nil;
}

- (void)saveObject:(NSObject *)object forKey:(NSString *)key
{
	if ( nil == object )
	{
		[self deleteCache:key];
	}
	else
	{
		NSData * data = [self serialize:object];
		if ( data )
		{
			[self saveData:data forKey:key];
		}
	}
}


- (void)setCache:(NSString*)key Value:(id)value Seconds:(double)seconds ValueCacheInFile:(BOOL)cacheInFile
{
    if ([m_dicCache objectForKey:key])
    {
        [self deleteCache:key];
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:seconds];
    NSTimeInterval timeDate = [date timeIntervalSince1970];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    BOOL isCacheInFile = cacheInFile;
    [dic setObject:[NSNumber numberWithBool:isCacheInFile] forKey:KFile];
    [dic setObject:[NSNumber numberWithDouble:timeDate] forKey:KExpires];
    
    if (isCacheInFile)
    {
        [self saveObject:value forKey:key];
    }
    else
    {
        [dic setObject:value forKey:KValue];
    }
    [m_dicCache setObject:dic forKey:key];
    [self updateCfg];
    KCRelease(dic);
}

- (void)setCache:(NSString*)key Value:(id)value Seconds:(double)seconds
{
    [self setCache:key Value:value Seconds:seconds ValueCacheInFile:NO];
}

- (void)setCacheAuto:(NSString*)key Value:(id)value Seconds:(double)seconds
{
    BOOL isCacheInFile = NO;
    if ([value isKindOfClass:[NSString class]])
    {
        NSUInteger length = [(NSString*)value length];
        if (length>1024)
        {
            isCacheInFile = YES;
        }
    }
    else if([value isKindOfClass:[NSData class]])
    {
        NSUInteger length = [(NSData*)value length];
        if (length>1024)
        {
            isCacheInFile = YES;
        }
    }
    else if([value isKindOfClass:[NSDictionary class]])
    {
        isCacheInFile = YES;
    }
    else if([value isKindOfClass:[NSArray class]])
    {
        isCacheInFile = YES;
    }
    
    [self setCache:key Value:value Seconds:seconds ValueCacheInFile:isCacheInFile];
}

-(BOOL)isOutTime:(NSTimeInterval)dateExpires
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:dateExpires];
//    DLog(@"%@",date);
    return ([date compare:[NSDate date]] == NSOrderedAscending);
}

- (id)getCache:(NSString*)key
{
    if (!m_dicCache || !key) return nil;
    NSDictionary* dic = [m_dicCache objectForKey:key];
    if(!dic || dic.count == 0) return nil;
    NSNumber* numDate = [dic objectForKey:KExpires];
    if ([self isOutTime:[numDate doubleValue]] )//out time
    {
        [self deleteCache:key];
        return nil;
    }
    NSNumber* numIsFile = [dic objectForKey:KFile];
    BOOL isFile = [numIsFile boolValue];
    if(!isFile)
    {
        return [dic objectForKey:KValue];
    }
    else
    {
        //读取文件
        return [self objectForKey:key];
    }
    
    return nil;
}


-(void)deleteCache:(NSString*)key
{
    NSDictionary* dic = [m_dicCache objectForKey:key];
    NSNumber* numIsFile = [dic objectForKey:KFile];
    BOOL isFile = [numIsFile boolValue];
    if (isFile)
    {
        NSString* path = [self cacheFileNameWithKey:key];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [m_dicCache removeObjectForKey:key];
    [self updateCfg];
}

-(void)deleteUserCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheDirectory] error:nil];
    m_strCacheDirectory = nil;
}

//not flush memory
-(void)flushMemory
{
}

-(void)changeUserCache:(NSString*)user
{
    if([m_strCacheUser isEqualToString:user]) return;
    [m_dicCache removeAllObjects];
    m_dicCache = nil;
    m_strCacheDirectory = nil;
    m_strCacheUser = nil;
    m_strCacheUser = user;
    [self loadCfg];
}


- (BOOL)hasCached:(NSString *)key
{
    return [m_dicCache objectForKey:key] ? YES : NO;
}


-(void)cleanOutTimeCache
{
    @synchronized(self)
    {
        NSArray* arrAllKey = [m_dicCache allKeys];
        for (NSString* key in arrAllKey)
        {
            NSDictionary* dic = [m_dicCache objectForKey:key];
            NSNumber* numDate = [dic objectForKey:KExpires];
            if ([self isOutTime:[numDate doubleValue]] )//out time
            {
                [self deleteCache:key];
            }
        }
    }
}

@end
