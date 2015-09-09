//
//  KCImageCacheManager.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KCCache.h"

@interface KCImagePreCache : KCCache


-(void)prepareImage:(NSURL*)url;
-(void)prepareImageFile:(NSURL *)url;  //不添加到缓存 使用这个接口强制打开缓存，外部设置无效

typedef void (^fetchImageBlock)(UIImage* image, NSString* path, BOOL isFromCached);
-(void)prepareImage:(NSURL *)url keepMemoryCache:(BOOL)isKeepMemoryCache usingBlock:(fetchImageBlock)block;

-(void)openFileCache:(BOOL)isOpen;
-(void)setIsUseLastPathComponentForKey:(BOOL)use;

-(void)deleteCachePool;
- (void)flushMemory;

// use observer
-(BOOL)registerDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;


@end


@protocol UCImageCacheDelegate <NSObject>

-(void)fetchImage:(NSURL*)url Image:(UIImage*)image FromCached:(BOOL)isFromCached;
-(void)fetchImageFile:(NSURL *)url Path:(NSString*)path FromCached:(BOOL)isFromCached;

@end