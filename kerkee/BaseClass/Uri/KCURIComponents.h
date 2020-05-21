//
//  KCURIComponents.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KCURIComponents : NSObject <NSCopying>
{
  @private
    NSString*   m_scheme;
    NSString*   m_user;
    NSString*   m_password;
    NSString*   m_host;
    NSNumber*   m_port;
    NSString*   m_path;
    NSString*   m_query;
    NSString*   m_fragment;
    NSArray* m_pathSegments;
}

/**
 Initialize a `KCURIComponents` with the components of a URL.
 
 If the url string from the NSURL is malformed, nil is returned.
 
 If `resolve` is `YES` and `url` is a relative URL, the components of `[url absoluteURL]`
 are used. As a general rule, clients should pass in `YES` unless they're
 specifically interested in the components of only the relative portion of a
 relative URL.
 
 @param url The URL whose components you want.
 @param resolve Whether to resolve relative URLs before retrieving components
 */
- (id)initWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve;

/**
 Initializes and returns a newly created `KCURIComponents` with the components of a URL.
 
 If the url string from the NSURL is malformed, nil is returned.
 
 If `resolve` is `YES` and `url` is a relative URL, the components of `[url absoluteURL]`
 are used. As a general rule, clients should pass in `YES` unless they're
 specifically interested in the components of only the relative portion of a
 relative URL.
 
 @param url The URL whose components you want.
 @param resolve Whether to resolve relative URLs before retrieving components
 */
+ (id)componentsWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve;

/**
 Initialize a `KCURIComponents` with a URL string.
 
 If the URLString is malformed, `nil` is returned.
 */
- (id)initWithString:(NSString *)aURLString;

/**
 Initializes and returns a newly created `KCURIComponents` with a URL string.
 
 If the URLString is malformed, `nil` is returned.
 */
+ (id)componentsWithString:(NSString *)aURLString;

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
 Returns a URL created from the `KCURIComponents` relative to a base URL.
 
 If the `KCURIComponents` has an authority component (user, password, host or port)
 and a path component, then the path must either begin with `/` or be an empty
 string. If the `KCURIComponents` does not have an authority component (user, password, host or port)
 and has a path component, the path component must not start with `//`. If those
 requirements are not met, `nil` is returned.
 */
- (NSURL *)URLRelativeToURL:(NSURL *)aBaseURL;

// Warning: IETF STD 66 (rfc3986) says the use of the format "user:password" in the userinfo subcomponent of a URI is deprecated because passing authentication information in clear text has proven to be a security risk. However, there are cases where this practice is still needed, and so the user and password components and methods are provided.

// Getting these properties removes any percent encoding these components may have (if the component allows percent encoding). Setting these properties assumes the subcomponent or component string is not percent encoded and will add percent encoding (if the component allows percent encoding).
@property (nonatomic, copy) NSString *scheme; // Attempting to set the scheme with an invalid scheme string will cause an exception.
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSNumber *port; // Attempting to set a negative port number will cause an exception.
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, copy) NSString *fragment;

// Getting these properties retains any percent encoding these components may have. Setting most of these properties is currently not supported as I am lazy and doing so is rarely useful. If you do have a use case, please send me a pull request or file an issue on GitHub.
@property (nonatomic, copy, readonly) NSString *percentEncodedUser;
@property (nonatomic, copy, readonly) NSString *percentEncodedPassword;
@property (nonatomic, copy, readonly) NSString *percentEncodedHost;
@property (nonatomic, copy, readonly) NSString *percentEncodedPath;
@property (nonatomic, copy) NSString *percentEncodedQuery;
@property (nonatomic, copy, readonly) NSString *percentEncodedFragment;

/**
 * Gets the decoded path segments.
 *
 * @return decoded path segments, each without a leading or trailing '/'
 */
- (NSArray*)getPathSegments;

/**
 * Gets the decoded last segment in the path.
 *
 * @return the decoded last segment or nil if the path is empty
 */
- (NSString*)getLastPathSegment;

@end
