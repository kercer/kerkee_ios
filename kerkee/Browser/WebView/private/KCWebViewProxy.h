//
//  KCWebViewProxy.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#import <Cocoa/Cocoa.h>
#define KCWebImageType NSImage
#define KCWebView_OSX
#else
#import <UIKit/UIKit.h>
#define KCWebImageType UIImage
#endif

typedef void (^KCStopLoadingHandler)();
@interface KCWebViewResponse : NSObject <NSURLConnectionDataDelegate>
@property (assign,nonatomic) NSURLCacheStoragePolicy cachePolicy;
@property (strong,nonatomic) NSURLRequest* request;
#pragma mark -
#pragma mark High level API
- (void) respondWithImage:(KCWebImageType*)aImage;
- (void) respondWithImage:(KCWebImageType*)aImage mimeType:(NSString*)aMimeType;
- (void) respondWithText:(NSString*)aText;
- (void) respondWithHTML:(NSString*)aHtml;
- (void) respondWithJSON:(NSDictionary*)aJsonObject;
- (void) handleStopLoadingRequest:(KCStopLoadingHandler)aStopLoadingHandler;
#pragma mark -
#pragma mark Low level API
- (void) setHeader:(NSString*)aHeaderName value:(NSString*)aHeaderValue;
- (void) setHeaders:(NSDictionary*)aHeaders;
- (void) respondWithStatusCode:(NSInteger)aStatusCode text:(NSString*)aText;
- (void) respondWithData:(NSData*)aData mimeType:(NSString*)aMimeType;
- (void) respondWithData:(NSData*)aData mimeType:(NSString*)aMimeType statusCode:(NSInteger)aStatusCode;
#pragma mark -
#pragma mark Pipe data API
- (void) pipeResponse:(NSURLResponse*)aResponse;
- (void) pipeData:(NSData*)aData;
- (void) pipeError:(NSError*)aError;
- (void) pipeEnd;
#pragma mark -
#pragma mark Private methods
- (id) _initWithRequest:(NSURLRequest*)aRequest protocol:(NSURLProtocol*)aProtocol;
- (void) _stopLoading;
@end

// The actual KCWebViewProxy API itself
typedef void (^KCWebViewHandler)(NSURLRequest* aReq, KCWebViewResponse* aRes);
@interface KCWebViewProxy : NSObject
+ (void) removeAllHandlers;
+ (void) handleRequestsWithScheme:(NSString*)aScheme handler:(KCWebViewHandler)aHandler;
+ (void) handleRequestsWithHost:(NSString*)aHost handler:(KCWebViewHandler)aHandler;
+ (void) handleRequestsWithHost:(NSString*)aHost path:(NSString*)aPath handler:(KCWebViewHandler)aHandler;
+ (void) handleRequestsWithHost:(NSString*)aHost pathPrefix:(NSString*)aPathPrefix handler:(KCWebViewHandler)aHandler;
+ (void) handleRequestsMatching:(NSPredicate*)aPredicate handler:(KCWebViewHandler)aHandler;
@end
