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


//static NSMutableDictionary *mRequestMap;

@interface KCXMLHttpRequestDispatcher ()

+ (id)objectInDictionary:(KCArgList *)dic forKey:(NSString *)key defaultValue:(NSString *)defaultValue;
//+ (KCXMLHttpRequest *)getXHRObject:(KCArgList *)args;

@end

@implementation KCXMLHttpRequestDispatcher
/*
__attribute__((constructor))
static void initializeClassMap()
{
    mRequestMap = [[NSMutableDictionary alloc] init];
}
*/
+ (KCXMLHttpRequest *)create:(KCWebView*)aWebView argList:(KCArgList *)args
{
    NSNumber *objectId = [args getArgValule:@"id"];
    KCXMLHttpRequest *xhr = [[KCXMLHttpRequest alloc] initWithObjectId:objectId WebView:aWebView];
    xhr.delegate = self;
    /*
    @synchronized (mRequestMap)
    {
        [mRequestMap setValue:xhr forKey:[objectId stringValue]];
    }
    */
    aWebView.xmlRequest = xhr;
    return xhr;
}

+ (void)open:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = aWebView.xmlRequest;//[self getXHRObject:args];
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
    
    //KCLog(@"sendArgs:%@", args);
}

+ (void)send:(KCWebView*)aWebView argList:(KCArgList *)args
{
    //KCLog(@"sendArgs:%@", args);
//    KCLog(@"%@",[args objectForKey:@"id"]);
    KCXMLHttpRequest *xhr = aWebView.xmlRequest;//[self getXHRObject:args];
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

+ (void)setRequestHeader:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = aWebView.xmlRequest;//[self getXHRObject:args];
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

+ (void)overrideMimeType:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = aWebView.xmlRequest;//[self getXHRObject:args];
    if (xhr)
    {
        [xhr overrideMimeType:[args getArgValule:@"mimetype"]];
    }
}

+ (void)abort:(KCWebView*)aWebView argList:(KCArgList *)args
{
    KCXMLHttpRequest *xhr = aWebView.xmlRequest;//[self getXHRObject:args];
    if (xhr)
    {
        [xhr abort];
    }
}

+ (id)objectInDictionary:(KCArgList *)dic forKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id obj = [dic getArgValule:key];
    if (obj)
    {
        return obj;
    }
    return defaultValue;
}
/*
+ (KCXMLHttpRequest *)getXHRObject:(KCArgList *)args
{
    NSNumber *objectId = [args getArgValule:@"id"];
    @synchronized (mRequestMap)
    {
        KCXMLHttpRequest *xhr = [mRequestMap objectForKey:[objectId stringValue]];
        return xhr;
    }  
}

+ (void)freeXMLHttpRequestObject:(NSNumber *)objectId
{
    if (objectId)
    {
        @synchronized (mRequestMap)
        {
            NSString *strObjectId = [objectId stringValue];
            KCXMLHttpRequest *xhr = [mRequestMap objectForKey:strObjectId];
            [mRequestMap removeObjectForKey:strObjectId];
            [KCApiBridge callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", strObjectId] WebView:[xhr webview]];
//            KCLog(@"==~~~ free object %d, %@", mRequestMap.count, objectId);
        }
    }
}
*/

+ (void)setPropertiesToJSSide:(NSDictionary *)properties Webview:(KCWebView*)webview
{
    [KCApiBridge callJSFunction:@"XMLHttpRequest.setProperties" withJSONObject:properties WebView:webview];
    
//    KCLog(@"%@",[properties objectForKey:@"id"]);
}




#pragma mark UCXMLHttpRequestDelegate
+(void)fetchReceiveData:(KCXMLHttpRequest*)xmlHttpRequest didReceiveData:(NSData *)data
{
    
}
+(void)fetchComplete:(KCXMLHttpRequest*)xmlHttpRequest responseData:(NSString*)aResponseData
{
//    KCLog(@"%@,%@",xmlHttpRequest.request.URL.absoluteString, [xmlHttpRequest.request allHTTPHeaderFields]);
//    [UCXMLHttpRequestDispatcher writeCached:xmlHttpRequest PropertiesData:properties];
    //[KCXMLHttpRequestDispatcher freeXMLHttpRequestObject:[xmlHttpRequest objectId]];
    
    [KCApiBridge callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", [xmlHttpRequest objectId]] WebView:[xmlHttpRequest webview]];
}
+(void)fetchFailed:(KCXMLHttpRequest*)xmlHttpRequest didFailWithError:(NSError *)error
{
    //[KCXMLHttpRequestDispatcher freeXMLHttpRequestObject: [xmlHttpRequest objectId]];
    [KCApiBridge callJS:[[NSString alloc] initWithFormat:@"XMLHttpRequest.deleteObject(%@)", [xmlHttpRequest objectId]] WebView:[xmlHttpRequest webview]];
}

@end
