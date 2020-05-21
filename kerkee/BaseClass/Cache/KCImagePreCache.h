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

typedef void (^fetchImageBlock)(UIImage* image, NSString* path, BOOL isFromCached);
-(void)prepareImage:(NSURL *)url keepMemoryCache:(BOOL)isKeepMemoryCache usingBlock:(fetchImageBlock)block;

//if you want use observr, you can register delegate or remove delegate
-(void)prepareImage:(NSURL*)url;
//if you want use observr, you can register delegate or remove delegate
//Do not add to the cache, Using this interface forced open the cache, the external Settings are invalid
-(void)prepareImageFile:(NSURL *)url;

-(void)openFileCache:(BOOL)isOpen;
-(void)setIsUseLastPathComponentForKey:(BOOL)use;

-(void)deleteCachePool;
-(void)cleanCacheWithBeforeDays:(int)aDays;
- (void)flushMemory;

// use observer
-(BOOL)registerDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;


@end


@protocol KCImageCacheDelegate <NSObject>

-(void)fetchImage:(NSURL*)url Image:(UIImage*)image FromCached:(BOOL)isFromCached;
-(void)fetchImageFile:(NSURL *)url Path:(NSString*)path FromCached:(BOOL)isFromCached;

@end