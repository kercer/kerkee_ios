//
//  KCImageCache.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//
 


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KCSingleton.h"
#import "KCCache.h"

@interface UIImageView (KCImageCache)

/*!
 * The view is not automatically resized.
 */
- (void)loadImageFromURL:(NSURL*)url;

@end

typedef void (^KCImageCacheBlock)(UIImage* image);

/*!
 * \warning This class is not thread-safe. You should use it from the main 
 * thread only.
 */
@interface KCImageCache : KCCache
{
	NSMutableDictionary* m_dicImages;
	NSMutableDictionary* m_dicLoadingImages;
	NSString* m_strCacheDirectory;
    
    /*! default is NO, if the value is YES, the key is url hash-lastPathComponent*/
    BOOL m_isUseLastPathComponentForKey;
}

AS_SINGLETON(KCImageCache);

- (void)imageFromURL:(NSURL*)url usingBlock:(KCImageCacheBlock)block;
- (void)imageFromURL:(NSURL*)url cacheInFile:(BOOL)cacheInFile usingBlock:(KCImageCacheBlock)block;

- (UIImage*)cachedImageWithURL:(NSURL*)url;


- (void)cacheImage:(UIImage*)image withURL:(NSURL*)url;

-(void)loadImageFileToCache:(NSURL*)url;

/*
 * image in file return path,if not in file return nil
 */
- (NSString*)imageFilePathWithURL:(NSURL*)url;

- (void)flushMemory;

-(void)flushMemoryWithURL:(NSURL*)url;

- (NSString*)cacheDirectory;

-(void)setCacheDirectory:(NSString*)dirPath;

-(void)deleteCachePool;
-(void)cleanCacheWithBeforeDays:(int)aDays;

-(void)setIsUseLastPathComponentForKey:(BOOL)use;

@end
