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
    NSString* urlManifest = aUri.URL.absoluteString;
    int index = [KCString lastIndexOfChar:'/' str:urlManifest];
    
    if (index>=0)
    {
        // index value can't -1
        NSString* urlDir = [urlManifest substringToIndex:index];
        KCURI* uriBase = [KCURI parse:urlDir];
        
        NSString* relativePath = [urlManifest substringFromIndex:index];
        
        [self fetchOneServerManifest:aUri baseUri:uriBase relativepath:relativePath block:aBlock];
    }

}

+ (void)fetchOneServerManifest:(KCURI*)aUri baseUri:(KCURI*)aBaseUri relativepath:(NSString*)aRelativePath block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aUri)
    {
        [self fetchData:aUri.URL finishedBlock:^(NSData *data)
         {
             KCManifestParser* parser = [[KCManifestParser alloc] init];
             KCManifestObject* manifestObject = [parser parserData:data];
             if (manifestObject)
             {
                 manifestObject.mBaseUri = aBaseUri;
                 manifestObject.mRelativePath = aRelativePath;
             }
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
    NSString* urlManifest = aUri.URL.absoluteString;
    int index = [KCString lastIndexOfChar:'/' str:urlManifest];
    if (index >= 0)
    {
        // index value can't -1
        NSString* urlDir = [urlManifest substringToIndex:index];
        KCURI* uriBase = [KCURI parse:urlDir];
        
        NSString* relativePath = [urlManifest substringFromIndex:index];
        
        [self fetchServerManifests:aUri outManifests:aOutMapManifestObjects baseUri:uriBase relativepath:relativePath block:aBlock];
    }
}

+ (void)fetchServerManifests:(KCURI*)aUri outManifests:(NSMutableDictionary*)aOutMapManifestObjects baseUri:(KCURI*)aBaseUri relativepath:(NSString*)aRelativePath block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aOutMapManifestObjects == NULL) return;
    
    [self fetchOneServerManifest:aUri baseUri:aBaseUri relativepath:aRelativePath block:^(KCManifestObject *aManifestObject)
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
                int indexRelative = [KCString lastIndexOfChar:'/' str:aRelativePath];
                NSString* relativeBase = [aRelativePath substringToIndex:indexRelative];
                for (int i = 0; i < subManifests.count; i++)
                {
                    NSString* subPathManifest = subManifests[i];
                    subPathManifest = [subPathManifest stringByReplacingOccurrencesOfString:@"./" withString:@""];
                    NSString* subUrlManifest = [NSString stringWithFormat:@"%@/%@", urlDir, subPathManifest];
                    NSString* relativePath = [NSString stringWithFormat:@"%@/%@", relativeBase, subPathManifest];
                    [self fetchServerManifests:[KCURI parse:subUrlManifest] outManifests:aOutMapManifestObjects baseUri:aBaseUri relativepath:relativePath block:aBlock];
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
    NSString* urlManifest = aUri.URL.absoluteString;
    int index = [KCString lastIndexOfChar:'/' str:urlManifest];
    if (index >= 0)
    {
        // index value can't -1
        NSString* urlDir = [urlManifest substringToIndex:index];
        KCURI* uriBase = [KCURI parse:urlDir];
        
        NSString* relativePath = [urlManifest substringFromIndex:index];
        
        return [self fetchOneLocalManifest:aUri baseUri:uriBase relativepath:relativePath];
    }
    return nil;
}

+ (KCManifestObject*)fetchOneLocalManifest:(KCURI*)aUri baseUri:(KCURI*)aBaseUri relativepath:(NSString*)aRelativePath
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
                manifestObject.mDestDir = [strPath kc_substring:0 end:[strPath kc_lastIndexOf:kFileSeparator]+1];
                
                manifestObject.mBaseUri = aUri;
                manifestObject.mRelativePath = aRelativePath;
            }
            return manifestObject;
        }
    }
    return nil;
}


+ (void)fetchOneLocalManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    NSString* urlManifest = aUri.URL.absoluteString;
    int index = [KCString lastIndexOfChar:'/' str:urlManifest];
    
    if (index>=0)
    {
        // index value can't -1
        NSString* urlDir = [urlManifest substringToIndex:index];
        KCURI* uriBase = [KCURI parse:urlDir];
        
        NSString* relativePath = [urlManifest substringFromIndex:index];
        
        [self fetchOneLocalManifest:aUri baseUri:uriBase relativepath:relativePath block:aBlock];
    }

}

+ (void)fetchOneLocalManifest:(KCURI*)aUri baseUri:(KCURI*)aBaseUri relativepath:(NSString*)aRelativePath block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_HIGH)
    KCManifestObject* manifestObject = [self fetchOneLocalManifest:aUri baseUri:aBaseUri relativepath:aRelativePath];
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
    NSString* urlManifest = aUri.URL.absoluteString;
    int index = [KCString lastIndexOfChar:'/' str:urlManifest];
    if (index >= 0)
    {
        // index value can't -1
        NSString* urlDir = [urlManifest substringToIndex:index];
        KCURI* uriBase = [KCURI parse:urlDir];
        
        NSString* relativePath = [urlManifest substringFromIndex:index];
        
        [self fetchLocalManifests:aUri outManifests:aOutMapManifestObjects baseUri:uriBase relativepath:relativePath block:aBlock];
    }
}

+ (void)fetchLocalManifests:(KCURI*)aUri outManifests:(NSMutableDictionary*)aOutMapManifestObjects  baseUri:(KCURI*)aBaseUri relativepath:(NSString*)aRelativePath block:(void(^)(KCManifestObject* aManifestObject))aBlock
{
    if (aOutMapManifestObjects == NULL) return;
    
    [self fetchOneLocalManifest:aUri baseUri:aBaseUri relativepath:aRelativePath block:^(KCManifestObject *aManifestObject) {
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
                int indexRelative = [KCString lastIndexOfChar:'/' str:aRelativePath];
                NSString* relativeBase = [aRelativePath substringToIndex:indexRelative];
                for (int i = 0; i < subManifests.count; i++)
                {
                    NSString* subPathManifest = subManifests[i];
                    subPathManifest = [subPathManifest stringByReplacingOccurrencesOfString:@"./" withString:@""];
                    NSString* subFullPath = [NSString stringWithFormat:@"%@%@", mo.mDestDir, subPathManifest];
                    NSString* relativePath = [NSString stringWithFormat:@"%@/%@", relativeBase, subPathManifest];
                    [self fetchLocalManifests:[KCURI parse:subFullPath] outManifests:aOutMapManifestObjects baseUri:aBaseUri relativepath:relativePath block:aBlock];
                }
            }
        }
    }];
}


@end
