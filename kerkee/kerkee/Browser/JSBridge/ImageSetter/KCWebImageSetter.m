//
//  KCImageSetter.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCWebImageSetter.h"
#import "KCBaseDefine.h"
#import "KCCacheKit.h"
#import "KCWebViewProxy.h"
#import "KCUtilURL.h"
#import "KCTaskQueue.h"

@interface KCWebImageSetter ()
{
    KCImagePreCache* m_imageCacheManager;
    
}
@end

@implementation KCWebImageSetter


-(id)init
{
    if (self = [super init])
    {
        if (!m_imageCacheManager)
        {
            m_imageCacheManager = [[KCImagePreCache alloc]init];
            [m_imageCacheManager setIsUseLastPathComponentForKey:YES];
            [m_imageCacheManager openFileCache:YES];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [m_imageCacheManager flushMemory];
    KCRelease(m_imageCacheManager);
    m_imageCacheManager = nil;
    
    KCDealloc(super);
}



-(void) handleImage:(KCWebImageSetterTask*)aTask
{
   
    
    NSURL *url = aTask.url;
    
    if ([KCUtilURL isImageUrl:url])
    {
        __weak KCImagePreCache* cache = m_imageCacheManager;
//        __block KCImagePreCache* cache = m_imageCacheManager;
        [KCWebViewProxy handleRequestsWithHost:url.host path:url.path handler:^(NSURLRequest *req, KCWebViewResponse *res)
         {
             BACKGROUND_GLOBAL_BEGIN(PRIORITY_BACKGROUND);
             [cache prepareImage:url keepMemoryCache:NO usingBlock:^(UIImage *image, NSString *path, BOOL isFromCached)
              {
                  [res respondWithImage:image];
              }];
             BACKGROUND_GLOBAL_COMMIT
             
         }];
        
        
//        if([url.scheme isEqualToString:@"http"])
//        {
//            [UCWebViewProxy handleRequestsWithHost:url.host path:url.path handler:^(NSURLRequest *req, UCWebViewResponse *res) {
///                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:req.URL] queue:queue completionHandler:^(NSURLResponse *netRes, NSData *data, NSError *netErr) {
////                    if (netErr || ((NSHTTPURLResponse*)netRes).statusCode >= 400) { return [res respondWithError:500 text:@":("]; }
////                    [res respondWithData:data mimeType:@"image/png"];
        ////                }];
//
//                NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"];
//                UIImage* image = [UIImage imageWithContentsOfFile:filePath];
//                [res respondWithImage:image];
//            }];
//        }
    }
    
    //KCLog(@"\n-----------------------\n%@\n-----------------------\n", url.absoluteString);
    
    
}



@end