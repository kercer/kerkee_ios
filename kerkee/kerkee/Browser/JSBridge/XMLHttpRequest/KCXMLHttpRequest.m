//
//  KCXMLHttpRequest.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import "KCXMLHttpRequest.h"
#import "KCBaseDefine.h"
#import "KCApiBridge.h"
#import "KCJSExecutor.h"

#define UNSET               0
#define OPENED              1
#define HEADERS_RECEIVED    2
#define LOADING             3
#define DONE                4

@interface KCXMLHttpRequest ()
{
    NSNumber *mObjectId;
    NSURLConnection *mConnection;
    NSMutableURLRequest *mRequest;
    NSString *mResponseCharset; // for example: gbk, gb2312, etc.
    NSMutableData *mReceivedData;
    
    BOOL mAborted;
    int mState;
}

@property (nonatomic,weak)KCWebView* mWebView;

- (void)createHttpRequestWithMethod:(NSString *)method url:(NSString *)url;
- (void)callJSSetProperties:(NSDictionary *)properties;
- (void)handleHeaders:(NSHTTPURLResponse *)response;
- (void)returnError:(KCWebView*)aWebView statusCode:(int)aStatusCode statusText:(NSString*)statusText;
- (void)returnResult:(KCWebView*)aWebview statusCode:(int)aStatusCode statusText:(NSString*)aStatusText responseText:(NSString*)aResponseText;

@end

@implementation KCXMLHttpRequest

@synthesize delegate = _delegate;

- (id)initWithObjectId:(NSNumber *)objectId WebView:(KCWebView*)webview
{
    self = [super init];
    if (self)
    {
        mObjectId = objectId;
        _mWebView = webview;
        mState = UNSET;
    }
    return self;
}

- (void)dealloc
{
    [self abort];
    _mWebView = nil;
    KCDealloc(super);
}

- (void)createHttpRequestWithMethod:(NSString *)method url:(NSString *)url
{
    if (method)
    {
        NSURL *urlObj = [[NSURL alloc] initWithString:url];
        //KCLog(@"SHFramework-url-----:%@", urlObj.absoluteString);
        mRequest = [[NSMutableURLRequest alloc] initWithURL:urlObj cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        if ([method caseInsensitiveCompare:@"GET"] == NSOrderedSame)
        {
            mRequest.HTTPMethod = @"GET";
        }
        else if ([method caseInsensitiveCompare:@"POST"] == NSOrderedSame)
        {
            mRequest.HTTPMethod = @"POST";
        }
        else if ([method caseInsensitiveCompare:@"HEAD"] == NSOrderedSame)
        {
            mRequest.HTTPMethod = @"HEAD";
        }
        else
        {
            [self returnError:_mWebView statusCode:405 statusText:@"Method Not Allowed"];
        }
    }
    else
    {
        [self returnError:_mWebView statusCode:405 statusText:@"Method Not Allowed"];
    }
}

- (void)returnError:(KCWebView*)aWebView statusCode:(int)aStatusCode statusText:(NSString*)aStatusText
{
    
    NSDictionary *jsonObj = [[NSDictionary alloc] initWithObjectsAndKeys:
                             mObjectId, @"id",
                             [[NSNumber alloc] initWithInt:DONE], @"readyState",
                             [[NSNumber alloc] initWithInt:aStatusCode], @"status",
                             aStatusText, @"statusText",
                             nil];
    [self callJSSetProperties:jsonObj];
    
    [self notifyFetchFailed:nil];
    //KCLog(@"returnError------readyState=%ld",DONE);
    
    mState = DONE;
    
}

//if statusCode is 200, aStatusText is "OK"
- (void)returnResult:(KCWebView*)aWebview statusCode:(int)aStatusCode statusText:(NSString*)aStatusText responseText:(NSString*)aResponseText
{
    if (mAborted)
        return;
    
    NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [mObjectId stringValue], @"id",
                                [[NSNumber alloc] initWithInt:DONE], @"readyState",
                                [[NSNumber alloc] initWithInt:aStatusCode], @"status",
                                aStatusText, @"statusText",
                                aResponseText, @"responseText",
                                nil];
    
    [self callJSSetProperties:properties];
    
    //KCLog(@"returnResult------readyState=%d ,textLenght=%ld",DONE,[aResponseText length]);
    
    mState = DONE;
    
}


/**
 * The reason that userAgent and referer are not set in the constructor is
 * that XMLHttpRequest.constructor in the JS layer may be called only once,
 * while XMLHttpRequest.open may be called multiple times. In this case, we
 * still have to create a brand new XMLHttpRequest object internally in the
 * Java layer, in which case we have no way of acquiring userAgent of the
 * browser and referer of the current request, but JS#XMLHttpRequest.open
 * can send them to us here.
 *
 * @param method    - GET/POST/HEAD
 * @param url       - the url to request
 * @param userAgent - User-Agent of the browser(currently WebView)
 * @param referer   - referer of the current request
 */
- (void)open:(NSString *)method url:(NSString *)url userAgent:(NSString *)userAgent referer:(NSString *)referer cookie:(NSString *)cookie
{
    [self createHttpRequestWithMethod:method url:url];
    if (mRequest)
    {
        [mRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        if (referer && ![referer isKindOfClass:[NSNull class]])
        {
            [mRequest setValue:referer forHTTPHeaderField:@"Referer"];            
        }
        
        if (cookie && ![cookie isKindOfClass:[NSNull class]])
        {
            [mRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
        }
    }
}


/**
 * for GET and HEAD start data transmission(sending the request and reading
 * the response)
 */
- (void)send
{
    mState = OPENED;
    
    // open() must be called before calling send()
    if (!mRequest)
        return;
    
    mAborted = false;
    
    mConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self];
    if (mConnection)
    {
        mReceivedData = [[NSMutableData alloc] init];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(fetchFailed:didFailWithError:)])
        {
            [self.delegate fetchFailed:self didFailWithError:nil];
        }
    }
    [mConnection start];
}

- (void)send:(NSString *)data
{
    if (!mRequest)
        return;
    
    // here we assume 'data' is urlencoded, and the client has already set the 'application/x-www-form-urlencoded' header
    mRequest.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self send];
}

- (void)setRequestHeader:(NSString *)headerName headerValue:(NSString *)headerValue
{
    [mRequest setValue:headerValue forHTTPHeaderField:headerName];
    
    //KCLog(@"headerName=%@, headerValue=%@",headerName, headerValue);
}

// "text/html;charset=gbk", "gbk" will be extracted, others will be ignored.
- (void)readCharset:(NSString *)mimeType
{
    NSArray *arr = [mimeType componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";="]];
    for (int i = 0; i < arr.count; ++i)
    {
        NSString *s = [arr objectAtIndex:i];
        s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([s caseInsensitiveCompare:@"charset"] == NSOrderedSame)
        {
            if (i + 1 < arr.count)
            {
                mResponseCharset = [arr objectAtIndex:i + 1] ;
                KCRetain(mResponseCharset);
            }
            break;
        }
    }
}

- (void)overrideMimeType:(NSString *)mimeType
{
    [self readCharset:mimeType];
}

- (BOOL)isOpened
{
    return mState == OPENED;
}

- (void)abort
{
    if (!mAborted && mState != DONE)
    {
        mAborted = true;
        [mConnection cancel];
    }
}

- (void)handleHeaders:(NSHTTPURLResponse *)response
{
    NSString* contentType = [response.allHeaderFields objectForKey:@"Content-Type"];
    [self readCharset:contentType];
    
    NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [mObjectId stringValue], @"id",
                                [[NSNumber alloc] initWithInt:HEADERS_RECEIVED], @"readyState",
                                [[NSNumber alloc] initWithInteger:response.statusCode], @"status",
                                [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], @"statusText",
                                response.allHeaderFields, @"headers",
                                nil];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:properties options:NSJSONWritingPrettyPrinted error:nil];
//    [self setPropertiesToJSSide:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [self callJSSetProperties:properties];
    
    
    //KCLog(@"allHeaderFields---%@",  response.allHeaderFields);
}

- (void)callJSSetProperties:(NSDictionary *)aProperties
{
    [KCJSExecutor callJSFunction:@"XMLHttpRequest.setProperties" withJSONObject:aProperties WebView:_mWebView];
}

#pragma mark --
#pragma mark net delegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    [self handleHeaders:(NSHTTPURLResponse *)aResponse];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    [mReceivedData appendData:aData];

    [self notifyFetchReceiveData:aData];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)aError
{
    KCLog(@">>>>> %@, URL:%@", aError.localizedDescription, mRequest.URL);

    [self notifyFetchFailed:aError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if (mResponseCharset)
    {
        CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)mResponseCharset);
        encoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
    }
    
    NSString* receivedData = [[NSString alloc] initWithData:mReceivedData encoding:encoding];
    KCAutorelease(receivedData);
    
    
    [self returnResult:_mWebView statusCode:200 statusText:@"OK" responseText:receivedData];
    
//    KCLog(@"properties:%@", properties);
    
    //KCLog(@"XHR----DONE  %@, %@：\n %@", mRequest.URL.path, mObjectId, receivedData);

    [self notifyFetchComplete:receivedData];
}


#pragma mark --
#pragma mark fetch notify

-(void)notifyFetchReceiveData:(NSData *)aData
{
    if([self.delegate respondsToSelector:@selector(fetchReceiveData:didReceiveData:)])
    {
        [self.delegate fetchReceiveData:self didReceiveData:aData];
    }
}

-(void)notifyFetchComplete:(NSString*)aResponseData
{
    if([self.delegate respondsToSelector:@selector(fetchComplete:responseData:)])
    {
        [self.delegate fetchComplete:self responseData:aResponseData];
    }
}


-(void)notifyFetchFailed:(NSError*)aError
{
    if ([self.delegate respondsToSelector:@selector(fetchFailed:didFailWithError:)])
    {
        [self.delegate fetchFailed:self didFailWithError:aError];
    }
}


#pragma mark --
#pragma mark api

-(NSNumber*)objectId
{
    return mObjectId;
}

-(NSURLRequest*)request
{
    return mRequest;
}

-(BOOL)isGetMethod
{
    if(mRequest)
    {
        return ([mRequest.HTTPMethod caseInsensitiveCompare:@"GET"] == NSOrderedSame);
    }
    
    return NO;
}

-(KCWebView*)webview
{
    return _mWebView;
}






@end
