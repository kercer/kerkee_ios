//
//  KCFileCache.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCFileCache.h"
#import "KCBaseDefine.h"

@interface KCFileCache ()
{
    
}

@end

@implementation KCFileCache


-(id)initWithCacheUser:(NSString*)user
{
    if (self = [super init])
    {
        m_strCacheUser = user;
        KCRetain(m_strCacheUser);
    }
    return self;
}

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
            KCLog(@"%@", m_strCacheDirectory);
            m_strCacheDirectory = [m_strCacheDirectory stringByAppendingFormat:@"/%@/", m_strCacheUser];
            KCLog(@"%@", m_strCacheDirectory);
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
    NSString* keyHash = [NSString stringWithFormat:@"%lu", (unsigned long)[key hash]];
    NSString* path = nil;
    path = [[self cacheDirectory] stringByAppendingPathComponent:keyHash];
//    DLog(@"dataCache Path:%@", path);
    return path;
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
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}



- (BOOL)hasCached:(NSString *)key
{
    NSString* path = [self cacheFileNameWithKey:key];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
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

- (void)setCache:(NSString*)key Value:(id)value
{
    if([self hasCached:key])
    {
        [self deleteCache:key];
    }
    
    [self saveObject:value forKey:key];
}

- (id)getCache:(NSString*)key
{
    return [self objectForKey:key];
}

-(void)deleteCache:(NSString *)key
{
    NSString* path = [self cacheFileNameWithKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
