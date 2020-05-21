//
//  KCWebViewProxy.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//




#include "KCWebViewProxy.h"
#import "KCBaseDefine.h"


static NSMutableArray* requestMatchers;
static NSPredicate* webViewUserAgentTest;
static NSPredicate* webViewProxyLoopDetection;


#define WORKAROUND_MUTABLE_COPY_LEAK 1

#if WORKAROUND_MUTABLE_COPY_LEAK
// required to workaround http://openradar.appspot.com/11596316
@interface NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround;

@end
#endif

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround
{
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:[self timeoutInterval]];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    if ([self HTTPBodyStream])
    {
        [mutableURLRequest setHTTPBodyStream:[self HTTPBodyStream]];
    }
    else
    {
        [mutableURLRequest setHTTPBody:[self HTTPBody]];
    }
    [mutableURLRequest setHTTPMethod:[self HTTPMethod]];
    
    return mutableURLRequest;
}

@end
#endif

// A request matcher, which matches a UIWebView request to a registered WebViewProxyHandler
@interface KCWebViewRequestMatcher : NSObject
@property (strong,nonatomic) NSPredicate* predicate;
@property (copy) KCWebViewHandler handler;
+ (KCWebViewRequestMatcher*)matchWithPredicate:(NSPredicate*)aPredicate handler:(KCWebViewHandler)aHandler;
@end
@implementation KCWebViewRequestMatcher
@synthesize predicate=_predicate, handler=_handler;
+ (KCWebViewRequestMatcher*)matchWithPredicate:(NSPredicate *)aPredicate handler:(KCWebViewHandler)aHandler
{
    KCWebViewRequestMatcher* matcher = [[KCWebViewRequestMatcher alloc] init];
    matcher.handler = aHandler;
    matcher.predicate = aPredicate;
    return matcher;
}
@end

#pragma mark - Protocol
// The NSURLProtocol implementation that allows us to intercept requests.
@interface KCWebViewURLProtocol : NSURLProtocol
{
    NSMutableURLRequest* m_correctedRequest;
    
    KCWebViewResponse* m_proxyResponse;
    KCWebViewRequestMatcher* m_requestMatcher;
}
@property (strong, nonatomic, readonly) NSURLRequest* correctedRequest;
@property (strong,nonatomic) KCWebViewResponse* proxyResponse;
@property (strong,nonatomic) KCWebViewRequestMatcher* requestMatcher;
+ (KCWebViewRequestMatcher*)findRequestMatcher:(NSURL*)url;
@end
@implementation KCWebViewURLProtocol
@synthesize proxyResponse=m_proxyResponse, requestMatcher=m_requestMatcher, correctedRequest = m_correctedRequest;


+ (KCWebViewRequestMatcher *)findRequestMatcher:(NSURL *)aUrl
{
    if (!requestMatchers || !aUrl) return nil;
    @synchronized(requestMatchers)
    {
        NSArray* requestMatchersTmp = [requestMatchers copy];
        if (!requestMatchersTmp) return nil;
        unsigned long count = requestMatchersTmp.count;
        for (int i = 0 ; i < count; ++i)
        {
            KCWebViewRequestMatcher* requestMatcher = [requestMatchersTmp objectAtIndex:i];
            if (requestMatcher && requestMatcher.predicate && [requestMatcher.predicate evaluateWithObject:aUrl])
            {
                return requestMatcher;
            }
        }
    }
    return nil;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    if (!aRequest) return NO;
    NSString* userAgent = aRequest.allHTTPHeaderFields[@"User-Agent"];
    if (userAgent && ![webViewUserAgentTest evaluateWithObject:userAgent]) { return NO; }
    if ([webViewProxyLoopDetection evaluateWithObject:aRequest.URL]) { return NO; }
    return ([self findRequestMatcher:aRequest.URL] != nil);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)aRequest
{
    return aRequest;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    // TODO Implement this here, or expose it through WebViewProxyResponse?
    return NO;
}

- (id)initWithRequest:(NSURLRequest *)aRequest cachedResponse:(NSCachedURLResponse *)aCachedResponse client:(id<NSURLProtocolClient>)aClient
{
    if (self = [super initWithRequest:aRequest cachedResponse:aCachedResponse client:aClient])
    {
        NSMutableURLRequest *connectionRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
        [[self request] mutableCopyWorkaround];
#else
        [[self request] mutableCopy];
#endif
        
        // TODO How to handle cachedResponse?
        m_correctedRequest = connectionRequest;
        NSString* correctedFragment;
        if (m_correctedRequest.URL.fragment)
        {
            correctedFragment = @"__webviewproxyreq__";
        }
        else
        {
            correctedFragment = @"#__webviewproxyreq__";
        }
        m_correctedRequest.URL = [NSURL URLWithString:[aRequest.URL.absoluteString stringByAppendingString:correctedFragment]];
        
        self.requestMatcher = [self.class findRequestMatcher:aRequest.URL];
        self.proxyResponse = [[KCWebViewResponse alloc] _initWithRequest:aRequest protocol:self];
    }
    return self;
}
- (void)startLoading
{
    self.requestMatcher.handler(m_correctedRequest, self.proxyResponse);
}
- (void)stopLoading
{
    m_correctedRequest = nil;
    [self.proxyResponse _stopLoading];
    self.proxyResponse = nil;
}
@end

#pragma mark - Response

// This is the proxy response object, through which we send responses
@implementation KCWebViewResponse
{
    NSURLRequest* m_request;
    NSURLProtocol* m_protocol;
    NSMutableDictionary* m_headers;
    BOOL m_stopped;
    KCStopLoadingHandler m_stopLoadingHandler;
    
    NSURLCacheStoragePolicy m_cachePolicy;
}

@synthesize cachePolicy=m_cachePolicy, request=m_request;
- (id)_initWithRequest:(NSURLRequest *)aRequest protocol:(NSURLProtocol*)aProtocol
{
    if (self = [super init])
    {
        m_request = aRequest;
        m_protocol = aProtocol;
        m_headers = [NSMutableDictionary dictionary];
        m_cachePolicy = NSURLCacheStorageNotAllowed;
    }
    return self;
}
- (void) _stopLoading
{
    m_stopped = YES;
    if (m_stopLoadingHandler)
    {
        m_stopLoadingHandler();
        m_stopLoadingHandler = nil;
    }
}

#pragma mark -
#pragma mark High level API
- (void)respondWithImage:(KCWebImageType *)aImage
{
    if (!aImage) return;
    [self respondWithImage:aImage mimeType:nil];
}
- (void)respondWithImage:(KCWebImageType *)aImage mimeType:(NSString *)aMimeType
{
    if (!aImage) return;
    if (!aMimeType)
    {
        NSString* extension = m_protocol.request.URL.pathExtension;
        if(nil != extension)
        {
            extension = [extension lowercaseString];
        }
        
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
        {
            aMimeType = @"image/jpg";
        }
        else
        {
            if (![extension isEqualToString:@"png"])
            {
                KCLog(@"WebViewProxy: responding with default mimetype image/png");
            }
            aMimeType = @"image/png";
        }
    }
    [self _respondWithImage:aImage mimeType:aMimeType];
}

- (void)respondWithJSON:(NSDictionary *)aJsonObject
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:aJsonObject options:0 error:nil];
    [self respondWithData:data mimeType:@"application/json"];
}
- (void)respondWithText:(NSString *)aText
{
    NSData* data = [aText dataUsingEncoding:NSUTF8StringEncoding];
    [self respondWithData:data mimeType:@"text/plain"];
}
- (void)respondWithHTML:(NSString *)aHtml
{
    NSData* data = [aHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self respondWithData:data mimeType:@"text/html"];
}
- (void)handleStopLoadingRequest:(KCStopLoadingHandler)aStopLoadingHandler
{
    m_stopLoadingHandler = aStopLoadingHandler;
}

#pragma mark -
#pragma mark  Low level API
- (void)setHeader:(NSString *)aHeaderName value:(NSString *)aHeaderValue
{
    m_headers[aHeaderName] = aHeaderValue;
}
- (void)setHeaders:(NSDictionary *)aHeaders
{
    for (NSString* headerName in aHeaders)
    {
        [self setHeader:headerName value:aHeaders[headerName]];
    }
}
- (void)respondWithData:(NSData *)aData mimeType:(NSString *)aMimeType
{
    [self respondWithData:aData mimeType:aMimeType statusCode:200];
}
- (void)respondWithStatusCode:(NSInteger)aStatusCode text:(NSString *)aText
{
    NSData* data = [aText dataUsingEncoding:NSUTF8StringEncoding];
    [self respondWithData:data mimeType:@"text/plain" statusCode:aStatusCode];
}

- (void)respondWithData:(NSData *)aData mimeType:(NSString *)aMimeType statusCode:(NSInteger)aStatusCode
{
    if (m_stopped) { return; }
    if (!m_protocol) { return; }
    if (!m_headers[@"Content-Type"])
    {
        if (!aMimeType)
        {
            aMimeType = [self _mimeTypeOf:m_protocol.request.URL.pathExtension];
        }
        if (aMimeType)
        {
            m_headers[@"Content-Type"] = aMimeType;
        }
    }
    if (!m_headers[@"Content-Length"])
    {
        m_headers[@"Content-Length"] = [self _contentLength:aData];
    }
    @synchronized (m_protocol.client)
    {
        KCWebViewURLProtocol* protocol = (KCWebViewURLProtocol*)m_protocol;

        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:m_protocol.request.URL statusCode:aStatusCode HTTPVersion:@"HTTP/1.1" headerFields:m_headers];
            
//      if (protocol.correctedRequest && protocol.proxyResponse && protocol.client && [protocol.client respondsToSelector:@selector(URLProtocol:didReceiveResponse:cacheStoragePolicy:)])
        [protocol.client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:m_cachePolicy];
            
//      if (protocol.correctedRequest && protocol.proxyResponse && protocol.client && [protocol.client respondsToSelector:@selector(URLProtocol:didLoadData:)])
        [protocol.client URLProtocol:protocol didLoadData:aData];
            
//      if (protocol.correctedRequest && protocol.proxyResponse && protocol.client && [protocol.client respondsToSelector:@selector(URLProtocolDidFinishLoading:)])
        [protocol.client URLProtocolDidFinishLoading:protocol];
        
    }

}
- (NSString*) _mimeTypeOf:(NSString*)pathExtension
{
    static NSDictionary* mimeTypes = nil;
    if (mimeTypes == nil)
    {
        mimeTypes = @{
                      @"png": @"image/png",
                      @"jpg": @"image/jpg",
                      @"jpeg": @"image/jpg",
                      @"woff": @"font/woff",
                      @"ttf": @"font/opentype",
                      @"m4a": @"audio/mp4a-latm",
                      @"js": @"application/javascript; charset=utf-8",
                      @"html": @"text/html; charset=utf-8"
                      };
    }
    return mimeTypes[pathExtension];
}

#pragma mark -
#pragma mark Pipe API
- (void)pipeResponse:(NSURLResponse *)aResponse
{
    [self pipeResponse:aResponse cachingAllowed:NO];
}
- (void)pipeResponse:(NSURLResponse *)response cachingAllowed:(BOOL)cachingAllowed
{
    if (m_stopped) { return; }
    NSURLCacheStoragePolicy cachePolicy = cachingAllowed ? NSURLCacheStorageAllowed : NSURLCacheStorageNotAllowed;
    [m_protocol.client URLProtocol:m_protocol didReceiveResponse:response cacheStoragePolicy:cachePolicy];
}
- (void)pipeData:(NSData *)aData
{
    if (m_stopped) { return; }
    [m_protocol.client URLProtocol:m_protocol didLoadData:aData];
}
- (void)pipeEnd
{
    if (m_stopped) { return; }
    [m_protocol.client URLProtocolDidFinishLoading:m_protocol];
}
- (void)pipeError:(NSError *)aError
{
    if (m_stopped) { return; }
    [m_protocol.client URLProtocol:m_protocol didFailWithError:aError];
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    [self pipeResponse:aResponse];
}
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    [self pipeData:aData];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    [self pipeEnd];
}
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)aError
{
    [self pipeError:aError];
}

#ifdef KCWebView_OSX
// OSX version
- (void)_respondWithImage:(NSImage*)aImage mimeType:(NSString*)aMimeType
{
    NSData* data = [aImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:data];
    if ([aMimeType isEqualToString:@"image/jpg"])
    {
        data = [imageRep
                representationUsingType:NSJPEGFileType
                properties:@{ NSImageCompressionFactor:[NSNumber numberWithFloat:1.0] }];
    }
    else if ([aMimeType isEqualToString:@"image/png"])
    {
        data = [imageRep
                representationUsingType:NSPNGFileType
                properties:@{ NSImageInterlaced:[NSNumber numberWithBool:NO] }];
    }
    [self respondWithData:data mimeType:aMimeType];
}
- (NSString*)_contentLength:(NSData*)aData
{
    return [NSString stringWithFormat:@"%ld", aData.length];
}
#else
// iOS Version
- (void)_respondWithImage:(UIImage*)aImage mimeType:(NSString*)aMimeType
{
    if (!aImage) return;
    
    NSData* data = nil;
    if ([aMimeType isEqualToString:@"image/jpg"])
    {
        data = UIImageJPEGRepresentation(aImage, 1.0);
    }
    else if ([aMimeType isEqualToString:@"image/png"])
    {
        data = UIImagePNGRepresentation(aImage);
    }
    
    if (data)
        [self respondWithData:data mimeType:aMimeType];
}
- (NSString*)_contentLength:(NSData*)aData
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)aData.length];
}
#endif

@end




// This is the actual WebViewProxy API
@implementation KCWebViewProxy

__attribute__((constructor))
static void initializeSetting()
{
    [KCWebViewProxy removeAllHandlers];
    webViewUserAgentTest = [NSPredicate predicateWithFormat:@"self MATCHES '^Mozilla.*Mac OS X.*'"];
    webViewProxyLoopDetection = [NSPredicate predicateWithFormat:@"self.fragment ENDSWITH '__webviewproxyreq__'"];
    // e.g. "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403"
    [NSURLProtocol registerClass:[KCWebViewURLProtocol class]];
}

+ (void)load
{
#if ! __has_feature(objc_arc)
    [NSException raise:@"ARC_Required" format:@"WebViewProxy requires Automatic Reference Counting (ARC) to function properly. Bailing."];
#endif
}
//+ (void)initialize
//{
//
//}
+ (void)removeAllHandlers
{
    requestMatchers = [NSMutableArray array];
}
+ (void)handleRequestsWithScheme:(NSString *)aScheme handler:(KCWebViewHandler)aHandler
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"scheme MATCHES[cd] %@", aScheme];
    [self handleRequestsMatching:predicate handler:aHandler];
}
+ (void)handleRequestsWithHost:(NSString *)aHost handler:(KCWebViewHandler)aHandler
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"host MATCHES[cd] %@", aHost];
    [self handleRequestsMatching:predicate handler:aHandler];
}
+ (void)handleRequestsWithHost:(NSString *)aHost path:(NSString *)aPath handler:(KCWebViewHandler)aHandler
{
    aPath = [self _normalizePath:aPath];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"host MATCHES[cd] %@ AND path MATCHES[cd] %@", aHost, aPath];
    [self handleRequestsMatching:predicate handler:aHandler];
}
+ (void)handleRequestsWithHost:(NSString *)aHost pathPrefix:(NSString *)aPathPrefix handler:(KCWebViewHandler)aHandler
{
    aPathPrefix = [self _normalizePath:aPathPrefix];
    NSString* pathPrefixRegex = [NSString stringWithFormat:@"^%@.*", aPathPrefix];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"host MATCHES[cd] %@ AND path MATCHES[cd] %@", aHost, pathPrefixRegex];
    [self handleRequestsMatching:predicate handler:aHandler];
}
+ (void)handleRequestsMatching:(NSPredicate*)aPredicate handler:(KCWebViewHandler)aHandler
{
    @synchronized (requestMatchers)
    {
        // Match on any property of NSURL, e.g. "scheme MATCHES 'http' AND host MATCHES 'www.google.com'"
        [requestMatchers addObject:[KCWebViewRequestMatcher matchWithPredicate:aPredicate handler:aHandler]];
    }
}
+ (NSString *)_normalizePath:(NSString *)path
{
    if (![path hasPrefix:@"/"])
    {
        // Paths always being with "/", so help out people who forget it
        path = [@"/" stringByAppendingString:path];
    }
    return path;
}

@end
