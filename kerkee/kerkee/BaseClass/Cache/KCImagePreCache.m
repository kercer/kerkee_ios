//
//  KCImageCacheManager.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCImagePreCache.h"
#import "KCImageCache.h"
#import "KCBaseDefine.h"

@interface KCImagePreCache ()
{
    BOOL m_isOpenFileCache;
    NSMutableArray* m_arrDelegates;
    KCImageCache* m_imageCache;
}

@end

@implementation KCImagePreCache


-(id)init
{
    if (self = [super init])
    {
        m_imageCache = [[KCImageCache alloc]init];
//        [m_ImageCache setIsUseLastPathComponentForKey:YES];
    }
    return self;
}

-(void)dealloc
{
    [m_arrDelegates removeAllObjects];
    KCRelease(m_arrDelegates);
    m_arrDelegates = nil;
    KCRelease(m_imageCache);
    m_imageCache = nil;
    KCDealloc(super);
}

-(void)prepareImage:(NSURL*)url
{
    if(url == nil) return;

    UIImage* image = [self imageForURL:url];
    if (image != nil)
    {
        if(m_arrDelegates)
        {
            for (id delegate in m_arrDelegates)
            {
                if(delegate && [delegate respondsToSelector:@selector(fetchImage:Image:FromCached:)])
                    [delegate fetchImage:url Image:image FromCached:YES];
            }
        }
    }
    else
    {
        [self startDownload:url isKeepCache:YES];
    }
}

-(void)prepareImageFile:(NSURL *)url
{
    if(url == nil) return;
    
    m_isOpenFileCache = YES;
    
    NSString* path = [self imageFilePathForURL:url];
    if (path)
    {
        if(m_arrDelegates)
        {
            for (id delegate in m_arrDelegates)
            {
                if(delegate && [delegate respondsToSelector:@selector(fetchImageFile:Path:FromCached:)])
                    [delegate fetchImageFile:url Path:path FromCached:YES];
            }
        }
    }
    else
    {
        [self startDownload:url isKeepCache:NO];
    }
}


-(void)prepareImage:(NSURL *)url keepMemoryCache:(BOOL)isKeepMemoryCache usingBlock:(fetchImageBlock)block
{
    if(url == nil)
    {
        block(nil, nil, NO);
        return;
    }
    
    UIImage* imageTmp = [self imageForURL:url];
    if (imageTmp != nil)
    {
        NSString* path = [self imageFilePathForURL:url];
        block(imageTmp, path, YES);
        if (!isKeepMemoryCache)
        {
            [m_imageCache flushMemoryWithURL:url];
        }
    }
    else
    {
        [self startDownload:url isKeepCache:isKeepMemoryCache usingBlock:^(UIImage *image) {
            NSString* path = [self imageFilePathForURL:url];
            block(image, path, NO);
        }];
    }
    
}

- (void)startDownload:(NSURL*)url isKeepCache:(BOOL)isKeepCache
{
	[m_imageCache imageFromURL:url cacheInFile:m_isOpenFileCache usingBlock:^(UIImage* image)
     {
         if (isKeepCache)
         {
             if(m_arrDelegates)
             {
                 for (id delegate in m_arrDelegates)
                 {
                     if(delegate && [delegate respondsToSelector:@selector(fetchImage:Image:FromCached:)])
                         [delegate fetchImage:url Image:image FromCached:NO];
                 }
             }
         }
         else
         {
             [m_imageCache flushMemoryWithURL:url];
             
             if(m_arrDelegates)
             {
                 for (id delegate in m_arrDelegates)
                 {
                     if(delegate && [delegate respondsToSelector:@selector(fetchImageFile:Path:FromCached:)])
                         [delegate fetchImageFile:url Path:[self imageFilePathForURL:url] FromCached:NO];
                 }
             }
         }
         
     }];
}

- (void)startDownload:(NSURL*)url isKeepCache:(BOOL)isKeepCache usingBlock:(void(^)(UIImage* image))block
{
    [m_imageCache imageFromURL:url cacheInFile:m_isOpenFileCache usingBlock:^(UIImage* image)
     {
         block(image);
         if (!isKeepCache)
         {
             [m_imageCache flushMemoryWithURL:url];
         }
     }];
}


- (void)loadImageCache:(NSURL*)url
{
    //The purpose of this is the first image is loaded into the dic
    if(m_isOpenFileCache)
    {
        [m_imageCache loadImageFileToCache:url];
    }
}

- (UIImage*)imageForURL:(NSURL*)url
{
    [self loadImageCache:url]; //load cache first
	return [m_imageCache cachedImageWithURL:url];
}

-(NSString*)imageFilePathForURL:(NSURL*)url
{
    return [m_imageCache imageFilePathWithURL:url];
}

- (void)openFileCache:(BOOL)isOpen
{
    m_isOpenFileCache = isOpen;
}

-(void)setIsUseLastPathComponentForKey:(BOOL)use
{
    [m_imageCache setIsUseLastPathComponentForKey:use];
}


-(void)deleteCachePool
{
    [m_imageCache deleteCachePool];
}

-(void)cleanCacheWithBeforeDays:(int)aDays
{
    [m_imageCache cleanCacheWithBeforeDays:aDays];
}

- (void)flushMemory
{
    [m_imageCache flushMemory];
}

-(BOOL)registerDelegate:(id)delegate
{
    if(delegate == nil) return NO;
    if(m_arrDelegates == nil)
        m_arrDelegates = [[NSMutableArray alloc]init];
    if (![m_arrDelegates containsObject:delegate])
    {
        [m_arrDelegates addObject:delegate];
        return YES;
    }
    
    return NO;
}

-(void)removeDelegate:(id)delegate
{
    if(delegate==nil) return;
    if ([m_arrDelegates containsObject:delegate])
    {
        [m_arrDelegates removeObject:delegate];
    }
}

@end
