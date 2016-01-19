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

- (KCXMLHttpRequest *)create:(KCWebView*)aWebView argList:(KCArgList *)args
{
    NSNumber *objectId = [args getObject:@"id"];
    KCXMLHttpRequest *xhr = [[KCXMLHttpRequest alloc] initWithObjectId:objectId WebView:aWebView];
    KCAutorelease(xhr);
    xhr.delegate = self;
    
    [m_lock lock];
    [m_xhrMap setValue:xhr forKey:[objectId stringValue]];
    [m_lock unlock];
    
    return xhr;
}

- (void)open:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHR:args];
    if (!xhr)
    {
        xhr = [self create:aWebView argList:args];
    }
    NSString *method = [args getObject:@"method"];
    NSString *url = [args getObject:@"url"];
    NSString *userAgent = [self objectInArgList:args forKey:@"useragent" defaultValue:@"iOS"];
    NSString *referer = [args getObject:@"referer"];
    NSString *cookie = [args getObject:@"cookie"];
    
    [xhr open:method url:url userAgent:userAgent referer:referer cookie:cookie];
    
}

- (void)send:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHR:args];
    if (xhr)
    {
        if(![self readCached:xhr])
        {
            NSString *data = [args getObject:@"data"];
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
}

- (void)setRequestHeader:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest* xhr = [self getXHR:args];
    if (xhr)
    {
        NSString* headerName = [args getObject:@"headerName"];
        id headerValue = [args getObject:@"headerValue"];
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

- (void)overrideMimeType:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHR:args];
    if (xhr)
    {
        [xhr overrideMimeType:[args getObject:@"mimetype"]];
    }
}

- (void)abort:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHR:args];
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

- (KCXMLHttpRequest *)getXHR:(KCArgList *)args
{
    [m_lock lock];
    NSNumber *objectId = [args getObject:@"id"];
    KCXMLHttpRequest *xhr = [m_xhrMap objectForKey:[objectId stringValue]];
    [m_lock unlock];
    
    return xhr;
    
}


- (void)freeXMLHttpRequestObject:(NSNumber *)objectId
{
    if (objectId)
    {
        [m_lock lock];
        NSString *strObjectId = [objectId stringValue];
        KCXMLHttpRequest *xhr = [m_xhrMap objectForKey:strObjectId];
        [KCJSExecutor callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", strObjectId] WebView:[xhr webview]];

        [m_xhrMap removeObjectForKey:strObjectId];
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
    if (aResponseData)
        [self writeCached:xmlHttpRequest propertiesData:aResponseData];
    [self freeXMLHttpRequestObject:[xmlHttpRequest objectId]];
}
-(void)fetchFailed:(KCXMLHttpRequest*)xmlHttpRequest didFailWithError:(NSError *)error
{
    [self freeXMLHttpRequestObject: [xmlHttpRequest objectId]];
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
                [KCJSExecutor callJSFunction:@"XMLHttpRequest.setProperties" withJSONObject:dicMutableProperties WebView:aXHR.webview];
                
                return YES;
            }
        }
    }
    
    return NO;
}


@end
