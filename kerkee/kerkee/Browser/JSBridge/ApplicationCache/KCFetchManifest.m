//
//  KCFetchManifest.m
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCFetchManifest.h"
#import "KCManifestParser.h"
#import "KCFileManager.h"
#import "KCString.h"
#import "KCTaskQueue.h"


#define kFileSeparator (@"/")

@implementation KCFetchManifest

+ (NSURLSession *)session
{
    static NSURLSession *session;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return session;
}

+(void)fetchData:(NSURL*)aUrl finishedBlock:(void(^)(NSData *data))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:aUrl];
    NSURLSession *session = [self session];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error && block)
        {
            block(data);
        }
    }];
    [dataTask resume];
}


+ (void)fetchOneServerManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aUri)
    {
        [self fetchData:aUri.URL finishedBlock:^(NSData *data)
        {
            KCManifestParser* parser = [[KCManifestParser alloc] init];
            KCManifestObject* manifestObject = [parser parserData:data];
            if (aBlock)
                aBlock(manifestObject);
        }];
    }
}

+ (void)fetchServerManifests:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [self fetchServerManifests:aUri outManifests:dic block:aBlock];
    
    
}

+ (void)fetchServerManifests:(KCURI*)aUri outManifests:(NSMutableDictionary*)aOutMapManifestObjects block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aOutMapManifestObjects == NULL) return;
    
    [self fetchOneServerManifest:aUri block:^(KCManifestObject *aManifestObject)
    {
        KCManifestObject* mo  = aManifestObject;
        if (mo)
        {
            NSString* urlManifest = aUri.URL.absoluteString;
            int index = [KCString lastIndexOfChar:'/' str:urlManifest];
            // index value can't -1
            NSString* urlDir = [urlManifest substringToIndex:index];
            
            if (!mo.mDownloadUrl)
            {
                mo.mDownloadUrl =  [NSString stringWithFormat:@"%@%@", urlDir, mo.mDekRelativePath];
            }
            
            [aOutMapManifestObjects setObject:mo forKey:urlManifest];
            
            if (aBlock)
                aBlock(mo);
            
            NSArray* subManifests = mo.mSubManifests;
            if (subManifests)
            {
                for (int i = 0; i < subManifests.count; i++)
                {
                    NSString* subPathManifest = subManifests[i];
                    subPathManifest = [subPathManifest stringByReplacingOccurrencesOfString:@"./" withString:@""];
                    NSString* subUrlManifest = [NSString stringWithFormat:@"%@/%@", urlDir, subPathManifest];
                    [self fetchServerManifests:[KCURI parse:subUrlManifest] outManifests:aOutMapManifestObjects block:aBlock];
                }
            }
        }
    }];

}


+ (NSString*)toLocalManifestPath:(KCURI*)aUri
{
    NSString* strPath = aUri.URL.path;
    return strPath;
}

+ (KCManifestObject*)fetchOneLocalManifest:(KCURI*)aUri
{
    if (aUri)
    {
        NSString* strPath = [self toLocalManifestPath:aUri];
        if ([KCFileManager exists:strPath])
        {
            NSError* error = nil;
            NSData* data = [KCFileManager readFileAsData:strPath error:&error];
            KCManifestParser* parser = [[KCManifestParser alloc] init];
            KCManifestObject* manifestObject = [parser parserData:data];
            if (manifestObject)
            {
                manifestObject.mDestDir = [strPath substring:0 end:[strPath lastIndexOf:kFileSeparator]+1];
            }
            return manifestObject;
        }
    }
    return nil;
}
+ (void)fetchOneLocalManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_HIGH)
    KCManifestObject* manifestObject = [self fetchOneLocalManifest:aUri];
    FOREGROUND_BEGIN
    if (aBlock)
        aBlock(manifestObject);
    FOREGROUND_COMMIT
    BACKGROUND_GLOBAL_COMMIT
}

+ (void)fetchLocalManifests:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [self fetchLocalManifests:aUri outManifests:dic block:aBlock];
}

+ (void)fetchLocalManifests:(KCURI*)aUri outManifests:(NSMutableDictionary*)aOutMapManifestObjects block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aOutMapManifestObjects == NULL) return;
    
    [self fetchOneLocalManifest:aUri block:^(KCManifestObject *aManifestObject) {
        KCManifestObject* mo = aManifestObject;
        if (mo)
        {
            NSString* strPath = [self toLocalManifestPath:aUri];
            [aOutMapManifestObjects setObject:mo forKey:strPath];
            
            if (aBlock)
                aBlock(mo);
            
            NSArray* subManifests = mo.mSubManifests;
            if (subManifests)
            {
                for (int i = 0; i < subManifests.count; i++)
                {
                    NSString* subPathManifest = subManifests[i];
                    subPathManifest = [subPathManifest stringByReplacingOccurrencesOfString:@"./" withString:@""];
                    NSString* subFullPath = [NSString stringWithFormat:@"%@%@", mo.mDestDir, subPathManifest];
                    
                    [self fetchLocalManifests:[KCURI parse:subFullPath] outManifests:aOutMapManifestObjects block:aBlock];
                }
            }
        }
    }];
}


@end
