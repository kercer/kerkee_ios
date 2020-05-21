//
//  KCImageCache.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//
 


#import "KCImageCache.h"
#import "KCBaseDefine.h"
#import "KCTaskQueue.h"
#import "KCFileManager.h"
#import "NSDate+KCDate.h"

@implementation UIImageView (KCImageCache)

- (void)loadImageFromURL:(NSURL*)url
{
	__block __typeof__(self) blockSelf = self;
	[[KCImageCache sharedInstance] imageFromURL:url usingBlock:^(UIImage* theImage)
	{
		if (theImage != nil)
			blockSelf.image = theImage;
	}];
}

@end

@implementation KCImageCache


DEF_SINGLETON(KCImageCache);


- (void)dealloc
{
    KCRelease(m_dicImages);
    KCRelease(m_dicLoadingImages);
    KCRelease(m_strCacheDirectory);
    KCDealloc(super);
}

- (NSMutableDictionary*)m_dicImages
{
    @synchronized(self)
    {
        if (m_dicImages == nil)
        {
            m_dicImages = [NSMutableDictionary dictionaryWithCapacity:10];
            KCRetain(m_dicImages);
        }
    }
	return m_dicImages;
}

- (NSMutableDictionary*)m_dicLoadingImages
{
	if (m_dicLoadingImages == nil)
	{
		m_dicLoadingImages = [NSMutableDictionary dictionaryWithCapacity:5];
        KCRetain(m_dicLoadingImages);
	}
	return m_dicLoadingImages;
}

- (NSString*)cacheDirectory
{
	if (m_strCacheDirectory == nil)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* libraryDirectory = [paths objectAtIndex:0];

		m_strCacheDirectory = [[libraryDirectory
			stringByAppendingPathComponent:@"Private Documents"]
			stringByAppendingPathComponent:@"Image Cache"];
        KCRetain(m_strCacheDirectory);

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
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dirPath])
    {
        NSError* error = nil;
        if (![fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"Error creating directory: %@", [error description]);
    }
    m_strCacheDirectory = dirPath;
    KCRetain(m_strCacheDirectory);
}

- (NSString*)keyForURL:(NSURL*)url
{
    if(m_isUseLastPathComponentForKey)
        return [url lastPathComponent];
    else
        return [NSString stringWithFormat:@"%lu-%@", (unsigned long)[url hash], [url lastPathComponent]];
}

- (void)notifyBlocksForKey:(NSString*)key
{
	NSMutableArray* blocks = [[self.m_dicLoadingImages objectForKey:key] copy];

    if (blocks)
    {
        for (KCImageCacheBlock block in blocks)
        {
            // It is possible for the block to replace the image with another one;
            // for example, it may do post-processing and put the processed image
            // back into the cache under the same key. Because the image may be
            // changed out from under us, we must look it up anew on every loop.
            if (block)
                block([self.m_dicImages objectForKey:key]);
        }
        
        [self.m_dicLoadingImages removeObjectForKey:key];

    }
}

- (void)imageFromURL:(NSURL*)url usingBlock:(KCImageCacheBlock)block
{
	[self imageFromURL:url cacheInFile:YES usingBlock:block];
}

- (void)imageFromURL:(NSURL*)url cacheInFile:(BOOL)cacheInFile usingBlock:(KCImageCacheBlock)block
{
	NSString* key = [self keyForURL:url];

	// 1) If we have the image in memory, use it.

	UIImage* image = [self.m_dicImages objectForKey:key];
	if (image != nil)
	{
		block(image);
		return;
	}

	// 2) If we have the file locally stored, then load into memory and use it.

	NSString* path = nil;
	if (cacheInFile)
	{
		path = [[self cacheDirectory] stringByAppendingPathComponent:key];
		image = [UIImage imageWithContentsOfFile:path];
		if (image != nil)
		{
			[self.m_dicImages setObject:image forKey:key];
			block(image);
			return;
		}
	}

	// 3) If a download for this image is already pending, then add the block 
	//    to the list of blocks that will be invoked when the download is done.

	block = [block copy];  // move to heap!
    KCAutorelease(block);

	NSMutableArray* array = [self.m_dicLoadingImages objectForKey:key];
	if (array != nil)
	{
		[array addObject:block];
		return;
	}

	// 4) Download the image, store it in a local file (if allowed), and use it.

	array = [NSMutableArray arrayWithCapacity:3];
	[array addObject:block];
	[self.m_dicLoadingImages setObject:array forKey:key];


//	__block ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
//
//    if(cacheInFile)
//    {
//        [request setDownloadDestinationPath:path];
//        NSString * tempPath = [NSString stringWithFormat:@"%@.tmp", path];
//        [request setTemporaryFileDownloadPath:tempPath];
//        [request setAllowResumeForFileDownloads:YES];//断点续传
//    }
//    [request setDelegate:self];
//    [request startAsynchronous];
    
    
    [self downloadImage:url finishedBlock:^(NSData *aData) {
        BACKGROUND_BEGIN
        [aData writeToFile:path atomically:YES];
        BACKGROUND_COMMIT
        
        UIImage* image = [UIImage imageWithData:aData];
        if (image != nil)
        {
            [self.m_dicImages setObject:image forKey:key];
            KCRelease(image);
        }
        else
        {
            KCLog(@"KCImageCache requestFinished ERROR! NO IMAGE \n url=%@",url);
        }
        
        [self notifyBlocksForKey:key];
        
    }];

	
}


- (NSURLSession *)session
{
    static NSURLSession *session;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return session;
}

- (void)downloadImage:(NSURL*)aUrl finishedBlock:(void(^)(NSData *data))block
{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:aUrl];
    NSURLSession *session = [self session];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error && block)
        {
            block(data);
//          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
    [dataTask resume];
}

//- (void)requestFinished:(ASIHTTPRequest *)request
//{
//    UIImage* image = nil;
//     NSString* key = [self keyForURL:request.url];
//    if ([request responseStatusCode] == 200)
//    {
//        NSString* downloadPath = request.downloadDestinationPath;
//        if(downloadPath.length > 0)
//        {
//            image = [[UIImage alloc] initWithContentsOfFile:downloadPath];
//        }
//        else
//        {
//            NSData* data = [request responseData];
//            image = [[UIImage alloc] initWithData:data];
//        }
//        
//        if (image != nil)
//        {
//            [self.m_dicImages setObject:image forKey:key];
//            KCRelease(image);
//        }
//        else
//        {
//            KCLog(@"KCImageCache requestFinished ERROR! NO IMAGE");
//        }
//    }
//    else
//    {
//        KCLog(@"KCImageCache requestFinished ERROR! NET ERROR");
//    }
//    [self notifyBlocksForKey:key];
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    KCLog(@"%@", request.error);
//    NSString* key = [self keyForURL:request.url];
//    [self notifyBlocksForKey:key];
//}


- (UIImage*)cachedImageWithURL:(NSURL*)url
{
	return [self.m_dicImages objectForKey:[self keyForURL:url]];
}

- (void)cacheImage:(UIImage*)image withURL:(NSURL*)url
{
    @synchronized(self)
    {
        [self.m_dicImages setObject:image forKey:[self keyForURL:url]];
    }
}


-(void)loadImageFileToCache:(NSURL*)url
{
    NSString* key = [self keyForURL:url];
    
    UIImage* image = [self.m_dicImages objectForKey:key];
	if (image != nil)
	{
		return;
	}
    
    NSString* path = nil;
    path = [[self cacheDirectory] stringByAppendingPathComponent:key];
    image = [UIImage imageWithContentsOfFile:path];
    if (image != nil)
    {
        @synchronized(self)
        {
            [self.m_dicImages setObject:image forKey:key];
        }
        
        return;
    }
}


- (NSString*)imageFilePathWithURL:(NSURL*)url
{
    NSString* key = [self keyForURL:url];
    NSString* path = nil;
    path = [[self cacheDirectory] stringByAppendingPathComponent:key];
    if ([KCFileManager existsFast:path])
    {
        return path;
    }
    return nil;
}


- (void)flushMemory
{
	[m_dicImages removeAllObjects];
}

-(void)flushMemoryWithURL:(NSURL*)url
{
    NSString* key = [self keyForURL:url];
    @synchronized(self)
    {
        [m_dicImages removeObjectForKey:key];
    }
}

-(void)deleteCachePool
{
    [self flushMemory];
    NSString* cacheDirectoryPath = [self cacheDirectory];
    m_strCacheDirectory = nil;
    if ([KCFileManager exists:cacheDirectoryPath])
    {
        [KCFileManager remove:cacheDirectoryPath];
    }
}

-(void)cleanCacheWithBeforeDays:(int)aDays
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    NSArray* list = [KCFileManager listFilesInDir:[self cacheDirectory] deep:YES];
    NSUInteger count = list.count;
    for (NSUInteger i = 0; i<count; ++i)
    {
        NSString* path = [list objectAtIndex:i];
        if (path)
        {
            NSDate* date = [KCFileManager attributes:path].fileModificationDate;
            if ([date kc_daysBeforeDate:[NSDate date]] >= aDays)
                [KCFileManager remove:path];
        }
    }
    
    BACKGROUND_GLOBAL_COMMIT
}


-(void)setIsUseLastPathComponentForKey:(BOOL)use
{
    m_isUseLastPathComponentForKey = use;
}

@end
