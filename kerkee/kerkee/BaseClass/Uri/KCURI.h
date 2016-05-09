//
//  KCURI.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCURIComponents.h"
#import "KCURIQuery.h"

@interface KCURI : NSObject

/**
 Initialize a `KCURI` with a URL.
 
 If the url string from the NSURL is malformed, nil is returned.
 
 If `resolve` is `YES` and `url` is a relative URL, the components of `[url absoluteURL]`
 are used. As a general rule, clients should pass in `YES` unless they're
 specifically interested in the components of only the relative portion of a
 relative URL.
 
 @param url The URL.
 @param resolve Whether to resolve relative URLs
 */
- (id)initWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve;


/**
 Initialize a `KCURI` with a URL string.
 
 If the URLString is malformed, `nil` is returned.
 */
- (id)initWithString:(NSString *)aURLString;


/**
 parse the uri string to KCURI
 
 @param aUriString  is uri string
 */
+(KCURI*) parse:(NSString*)aUriString;


/**
 Returns a KCURIComponents
 */
-(KCURIComponents*)components;

/**
 Returns a KCURIQuery
 */
-(KCURIQuery*)query;

/**
 Returns aDictionary
 */
-(NSDictionary*)getQueries;


/**
 Returns a URL created from the `KCURIComponents`.
 
 If the `KCURIComponents` has an authority component (user, password, host or port)
 and a path component, then the path must either begin with `/` or be an empty
 string. If the `KCURIComponents` does not have an authority component (user, password, host or port)
 and has a path component, the path component must not start with `//`. If those
 requirements are not met, `nil` is returned.
 */
- (NSURL *)URL;


/**
 Returns the uri is absolute
 */
- (BOOL)isAbsolute;

/**
 Returns the uri is relative
 */
- (BOOL)isRelative;

- (NSArray*)getPathSegments;


@end
