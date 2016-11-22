//
//  KCXMLHttpRequestDispatcher.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCXMLHttpRequestDispatcher.h"
#import "KCXMLHttpRequest.h"
#import "KCBaseDefine.h"
#include "KCApiBridge.h"
#import "KCJSExecutor.h"
#import "KCJSDefine.h"
#import "KCTaskQueue.h"
#import "KCDataValidCache.h"
#import "KCURI.h"
#import "KCString.h"



@interface KCXMLHttpRequestDispatcher ()
{
    NSMutableDictionary *m_xhrMap;
    NSLock* m_lock;
}


@end

@implementation KCXMLHttpRequestDispatcher

- (id)init
{
    if (self = [super init])
    {
        m_xhrMap = [[NSMutableDictionary alloc] init];
        m_lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_xhrMap);
    m_xhrMap = nil;
    KCRelease(m_lock);
    m_lock = nil;
}


- (NSString*)getJSObjectName
{
    return kJS_XMLHttpRequest;
}


- (NSString*)keyFromWebViewAndId:(KCWebView*)aWebView objectID:(NSNumber*)aObjectID
{
    return [NSString stringWithFormat:@"%lu%@", (unsigned long)aWebView.hash, aObjectID];
}

- (KCXMLHttpRequest *)create:(KCWebView*)aWebView argList:(KCArgList *)args
{
    NSNumber *objectId = [args getObject:@"id"];
    
    KCXMLHttpRequest *xhr = [[KCXMLHttpRequest alloc] initWithObjectId:objectId WebView:aWebView];
    KCAutorelease(xhr);
    xhr.delegate = self;
    
    [m_lock lock];
    [m_xhrMap setValue:xhr forKey:[self keyFromWebViewAndId:aWebView objectID:objectId]];
    [m_lock unlock];
    
    return xhr;
}

- (void)open:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
//    BACKGROUND_BEGIN
    KCXMLHttpRequest *xhr = [self getXHR:aWebView argList:aArgs];
    if (!xhr)
    {
        xhr = [self create:aWebView argList:aArgs];
    }
    NSString *method = [aArgs getObject:@"method"];
    NSString *url = [aArgs getObject:@"url"];
    NSString *userAgent = [self objectInArgList:aArgs forKey:@"useragent" defaultValue:@"iOS"];
    NSString *referer = [aArgs getObject:@"referer"];
    NSString *cookie = [aArgs getObject:@"cookie"];
    NSString *scheme = [aArgs getString:@"scheme"];
    NSString *host = [aArgs getString:@"host"];
    NSString *port = [self objectInArgList:aArgs forKey:@"port" defaultValue:@""];
    NSString *href = [aArgs getString:@"href"];
    
    KCURI* uriUrl = [KCURI parse:url];
    BOOL isRelative = [uriUrl isRelative];
    if (isRelative)
    {
        NSArray* list = [uriUrl getPathSegments];
        NSUInteger nSegmentCount = list.count;
        if (nSegmentCount > 0)
        {
            NSString* tmpPath = [url startsWithChar:'/'] ? url : [NSString stringWithFormat:@"/%@", url];
            NSString* tmpPort = port.length > 0 ? [NSString stringWithFormat:@":%@", port] : @"";
            url = [NSString stringWithFormat:@"%@//%@%@%@",scheme, host, tmpPort, tmpPath];
            KCLog(@"%@", url);
        }
        else
        {
            url = href;
        }
    }
    
    
    [xhr open:method url:url userAgent:userAgent referer:referer cookie:cookie];
//    BACKGROUND_COMMIT
}

- (void)send:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
//    BACKGROUND_BEGIN
    KCXMLHttpRequest *xhr = [self getXHR:aWebView argList:aArgs];
    if (xhr)
    {
        if(![self readCached:xhr])
        {
            NSString *data = [aArgs getObject:@"data"];
            if (data)
            {
                [xhr send:data];
            }
            else
            {
                [xhr send];
            }
        }
    }
//    BACKGROUND_COMMIT
}

- (void)setRequestHeader:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
    KCXMLHttpRequest* xhr = [self getXHR:aWebView argList:aArgs];
    if (xhr)
    {
        NSString* headerName = [aArgs getObject:@"headerName"];
        id headerValue = [aArgs getObject:@"headerValue"];
        NSString* headerValueString=@"";
        if ([headerValue isKindOfClass:[NSString class]])
        {
            headerValueString = headerValue;
        }
        else if([headerValue isKindOfClass:[NSNumber class]])
        {
            headerValueString = [(NSNumber*)headerValue stringValue];
        }
        [xhr setRequestHeader:headerName headerValue:headerValueString];
    }
    
}

- (void)overrideMimeType:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
    KCXMLHttpRequest *xhr = [self getXHR:aWebView argList:aArgs];
    if (xhr)
    {
        [xhr overrideMimeType:[aArgs getObject:@"mimetype"]];
    }
}

- (void)abort:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
    KCXMLHttpRequest *xhr = [self getXHR:aWebView argList:aArgs];
    if (xhr)
    {
        [xhr abort];
    }
}

- (id)objectInArgList:(KCArgList *)dic forKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id obj = [dic getObject:key];
    if (obj)
    {
        return obj;
    }
    return defaultValue;
}

- (KCXMLHttpRequest *)getXHR:(KCWebView*)aWebView argList:(KCArgList *)aArgs
{
    [m_lock lock];
    NSNumber *objectId = [aArgs getObject:@"id"];
    KCXMLHttpRequest *xhr = [m_xhrMap objectForKey:[self keyFromWebViewAndId:aWebView objectID:objectId]];
    [m_lock unlock];
    
    return xhr;
    
}


- (void)freeXMLHttpRequestObject:(KCWebView*)aWebView objectID:(NSNumber *)aObjectID
{
    if (aObjectID)
    {
        [m_lock lock];
        
        NSString* strObjectID = [aObjectID stringValue];
        
        KCXMLHttpRequest *xhr = [m_xhrMap objectForKey:[self keyFromWebViewAndId:aWebView objectID:aObjectID]];
        FOREGROUND_BEGIN
        [KCJSExecutor callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", strObjectID] inWebView:[xhr webview] completionHandler:nil];
        FOREGROUND_COMMIT

        [m_xhrMap removeObjectForKey:[self keyFromWebViewAndId:aWebView objectID:aObjectID]];
//            KCLog(@"==~~~ free object %d, %@", mRequestMap.count, objectId);
        [m_lock unlock];

    }
}


#pragma mark KCXMLHttpRequestDelegate
-(void)fetchReceiveData:(KCXMLHttpRequest*)xmlHttpRequest didReceiveData:(NSData *)data
{
    
}
-(void)fetchComplete:(KCXMLHttpRequest*)xmlHttpRequest responseData:(NSDictionary*)aResponseData
{
    BACKGROUND_BEGIN
    if (aResponseData)
        [self writeCached:xmlHttpRequest propertiesData:aResponseData];
    [self freeXMLHttpRequestObject:xmlHttpRequest.webview  objectID:[xmlHttpRequest objectId]];
    BACKGROUND_COMMIT
}
-(void)fetchFailed:(KCXMLHttpRequest*)xmlHttpRequest didFailWithError:(NSError *)error
{
    BACKGROUND_BEGIN
    [self freeXMLHttpRequestObject:xmlHttpRequest.webview  objectID:[xmlHttpRequest objectId]];
    BACKGROUND_COMMIT
}


#pragma mark cache
-(BOOL)writeCached:(KCXMLHttpRequest*)aXHR propertiesData:(NSDictionary*)aProperties
{
    if(aProperties.count>0)
    {
        if ([aXHR isGetMethod])
        {
            NSURLRequest* request = [aXHR request];
            NSURL* url = request.URL;
            NSString* urlStr = url.absoluteString;
            NSString* cacheTime = [request valueForHTTPHeaderField:@"cache-time"];
            if (cacheTime)
            {
                double  cacheSec = [cacheTime doubleValue];
                if (cacheSec> 0)
                {
                    [[KCDataValidCache defaultCache] setCacheAuto:urlStr Value:aProperties Seconds:cacheSec];
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(BOOL)readCached:(KCXMLHttpRequest*)aXHR
{
    if ([aXHR isGetMethod])
    {
        NSURLRequest* request = [aXHR request];
        NSURL* url = request.URL;
        NSString* urlStr = url.absoluteString;
        NSString* cacheTime = [request valueForHTTPHeaderField:@"cache-time"];
        if (cacheTime && [cacheTime doubleValue] > 0)
        {
            NSDictionary* dicProperties = [[KCDataValidCache defaultCache] getCache:urlStr];
            
            if (dicProperties && dicProperties.count > 0)
            {
                NSMutableDictionary* dicMutableProperties = [[NSMutableDictionary alloc] initWithDictionary:dicProperties];
                KCRelease(dicMutableProperties);
                NSNumber *objectId = [aXHR objectId];
                [dicMutableProperties setObject:objectId forKey:@"id"];
                FOREGROUND_BEGIN
                [KCJSExecutor callJSFunction:@"XMLHttpRequest.setProperties" withJSONObject:dicMutableProperties inWebView:aXHR.webview completionHandler:nil];
                FOREGROUND_COMMIT
                
                return YES;
            }
        }
    }
    
    return NO;
}


@end
