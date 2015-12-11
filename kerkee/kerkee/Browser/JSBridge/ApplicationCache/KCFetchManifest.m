//
//  KCFetchManifest.m
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCFetchManifest.h"
#import "KCManifestParser.h"


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


+ (void)fetchOneServerManifest:(KCURI*)aUri
{
    if (aUri)
    {
        [self fetchData:aUri.URL finishedBlock:^(NSData *data) {
            KCManifestParser* parser = [[KCManifestParser alloc] init];
            [parser parserData:data];
            
        }];
    }

}


@end
