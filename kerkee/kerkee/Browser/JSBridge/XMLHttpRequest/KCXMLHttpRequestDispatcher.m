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



@interface KCXMLHttpRequestDispatcher ()
{
    NSMutableDictionary *mRequestMap;
}


@end

@implementation KCXMLHttpRequestDispatcher

__attribute__((constructor))
static void initializeClassMap()
{
}

- (id)init
{
    if (self = [super init])
    {
        mRequestMap = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


- (NSString*)getJSObjectName
{
    return kJS_XMLHttpRequest;
}

- (KCXMLHttpRequest *)create:(KCWebView*)aWebView argList:(KCArgList *)args
{
    NSNumber *objectId = [args getArgValule:@"id"];
    KCXMLHttpRequest *xhr = [[KCXMLHttpRequest alloc] initWithObjectId:objectId WebView:aWebView];
    xhr.delegate = self;
    
    @synchronized (mRequestMap)
    {
        [mRequestMap setValue:xhr forKey:[objectId stringValue]];
    }
    
    return xhr;
}

- (void)open:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHRObject:args];
    if (!xhr)
    {
        xhr = [self create:aWebView argList:args];
    }
    NSString *method = [args getArgValule:@"method"];
    NSString *url = [args getArgValule:@"url"];
    NSString *userAgent = [self objectInDictionary:args forKey:@"useragent" defaultValue:@"iOS"];
    NSString *referer = [args getArgValule:@"referer"];
    NSString *cookie = [args getArgValule:@"cookie"];
    
    [xhr open:method url:url userAgent:userAgent referer:referer cookie:cookie];
    
}

- (void)send:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHRObject:args];
    if (xhr)
    {
            //KCLog(@"%@",[args getArgValule:@"id"]);
            
            NSString *data = [args getArgValule:@"data"];
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

- (void)setRequestHeader:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHRObject:args];
    if (xhr)
    {
        NSString* headerName = [args getArgValule:@"headerName"];
        id headerValue = [args getArgValule:@"headerValue"];
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
    KCXMLHttpRequest *xhr = [self getXHRObject:args];
    if (xhr)
    {
        [xhr overrideMimeType:[args getArgValule:@"mimetype"]];
    }
}

- (void)abort:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = [self getXHRObject:args];
    if (xhr)
    {
        [xhr abort];
    }
}

- (id)objectInDictionary:(KCArgList *)dic forKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id obj = [dic getArgValule:key];
    if (obj)
    {
        return obj;
    }
    return defaultValue;
}

- (KCXMLHttpRequest *)getXHRObject:(KCArgList *)args
{
    NSNumber *objectId = [args getArgValule:@"id"];
    @synchronized (mRequestMap)
    {
        KCXMLHttpRequest *xhr = [mRequestMap objectForKey:[objectId stringValue]];
        return xhr;
    }  
}


- (void)freeXMLHttpRequestObject:(NSNumber *)objectId
{
    if (objectId)
    {
        @synchronized (mRequestMap)
        {
            NSString *strObjectId = [objectId stringValue];
            KCXMLHttpRequest *xhr = [mRequestMap objectForKey:strObjectId];
            [KCJSExecutor callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", strObjectId] WebView:[xhr webview]];

            [mRequestMap removeObjectForKey:strObjectId];
            
//            KCLog(@"==~~~ free object %d, %@", mRequestMap.count, objectId);
        }
    }
}


+ (void)setPropertiesToJSSide:(NSDictionary *)properties Webview:(KCWebView*)webview
{
    [KCJSExecutor callJSFunction:@"XMLHttpRequest.setProperties" withJSONObject:properties WebView:webview];
}




#pragma mark KCXMLHttpRequestDelegate
-(void)fetchReceiveData:(KCXMLHttpRequest*)xmlHttpRequest didReceiveData:(NSData *)data
{
    
}
-(void)fetchComplete:(KCXMLHttpRequest*)xmlHttpRequest responseData:(NSString*)aResponseData
{
    [self freeXMLHttpRequestObject:[xmlHttpRequest objectId]];
}
-(void)fetchFailed:(KCXMLHttpRequest*)xmlHttpRequest didFailWithError:(NSError *)error
{
    [self freeXMLHttpRequestObject: [xmlHttpRequest objectId]];
}

@end
