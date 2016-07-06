//
//  KCURI.m
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCURI.h"
#import "KCURIComponents.h"
#import "KCBaseDefine.h"
#import "KCUtilURL.h"

@interface KCURI ()
{
    KCURIComponents* m_uriComponents;
}

@end

@implementation KCURI

- (instancetype)initWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve
{
    if (self = [super init])
    {
        m_uriComponents = [KCURIComponents componentsWithURL:aUrl resolvingAgainstBaseURL:aIsResolve];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)aURLString
{
    NSURL *url = [[NSURL alloc] initWithString:aURLString];
    if (!url)
    {
        KCRelease(self);
        return nil;
    }
    
    self = [self initWithURL:url resolvingAgainstBaseURL:NO];   // already absolute
    
    KCRelease(url);
    return self;
}

- (instancetype)initWithString:(NSString *)aURLString relativeToURI:(KCURI*)aBaseURI
{
    if (aBaseURI)
    {
        if (aURLString)
        {
            KCURI* uri = [[KCURI alloc] initWithString:aURLString];
            NSURL* url = [uri.components URLRelativeToURL:aBaseURI.URL];
            self = [self initWithURL:url resolvingAgainstBaseURL:YES];
        }
        else
        {
            self = [self initWithURL:aBaseURI.URL resolvingAgainstBaseURL:YES];
        }

    }
    else
    {
        self = [self initWithString:aURLString];
    }
    return self;
}

+ (instancetype)URIWithString:(NSString*)aURLString
{
    return [self URIWithString:aURLString relativeToURI:nil];
}

+ (instancetype)URIWithString:(NSString*)aURLString relativeToURI:(KCURI*)aBaseURI
{
    KCURI* uri = [[KCURI alloc] initWithString:aURLString relativeToURI:aBaseURI];
    KCAutorelease(uri);
    return uri;
}

- (KCURI*)URIRelativeToURL:(KCURI*)aBaseURL
{
    if (!aBaseURL) return self;
    if (m_uriComponents)
    {
        NSURL* url = [m_uriComponents URLRelativeToURL:aBaseURL.URL];
        return [[KCURI alloc] initWithURL:url resolvingAgainstBaseURL:YES];
    }
    return nil;
}


-(void)dealloc
{
    KCRelease(m_uriComponents);
    m_uriComponents = nil;
    KCDealloc(super);
}


+(KCURI*) parse:(NSString*)aUriString
{
    KCURI* uri = [[KCURI alloc] initWithString:aUriString];
    KCAutorelease(uri);
    
    return uri;
}

-(KCURIComponents*)components
{
    return m_uriComponents;
}

-(KCURIQuery*)query
{
    return [KCURIQuery queryWithURL:m_uriComponents.URL];
}

-(NSDictionary*)getQueries
{
    NSURL* url = [[self components] URL];
    NSDictionary* dicQueries = nil;
//    dicQueries = [KCUtilURL getQuery:url];
    dicQueries = [KCURIQuery parametersFromURL:url];
    return dicQueries;
}

- (NSURL*)URL
{
    return m_uriComponents.URL;
}

- (BOOL)isAbsolute
{
    return ![self isRelative];
}

- (BOOL)isRelative
{
    return m_uriComponents && m_uriComponents.scheme == nil;
}

- (NSArray*)getPathSegments
{
    return m_uriComponents.getPathSegments;
}

- (NSString*)getLastPathSegment
{
    return m_uriComponents.getLastPathSegment;
}

- (NSString*)description
{
    return self.URL.absoluteString;
}

- (NSString*)debugDescription
{
    return self.URL.absoluteString;
}

@end
