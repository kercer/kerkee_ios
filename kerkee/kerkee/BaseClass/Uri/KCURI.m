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

- (id)initWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve
{
    if (self = [super init])
    {
        m_uriComponents = [KCURIComponents componentsWithURL:aUrl resolvingAgainstBaseURL:aIsResolve];
    }
    return self;
}

- (id)initWithString:(NSString *)aURLString
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

@end
