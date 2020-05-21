//
//  KCURIComponents.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCURIComponents.h"
#import "KCBaseDefine.h"
#import "KCUtilURI.h"
#import "KCString.h"


@interface KCURIComponents ()
@property (nonatomic, copy, readwrite) NSString* percentEncodedUser;
@property (nonatomic, copy, readwrite) NSString* percentEncodedPassword;
@property (nonatomic, copy, readwrite) NSString* percentEncodedHost;
@property (nonatomic, copy, readwrite) NSString* percentEncodedPath;
@property (nonatomic, copy, readwrite) NSString* percentEncodedFragment;
@end


@implementation KCURIComponents

#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aResolve;
{
    if (aResolve) aUrl = [aUrl absoluteURL];
    CFStringRef urlString = CFURLGetString((CFURLRef)aUrl);
    BOOL fudgedParsing = NO;
    
    self = [self init];
    
    
    // Default to empty path. NSURLComponents seems to basically do that; it's very hard to end up with a nil path
    self.percentEncodedPath = @"";
    
    
    // Avoid CFURLCopyScheme as it resolves relative URLs
    CFRange schemeRange = CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentScheme, NULL);
    if (schemeRange.location != kCFNotFound)
    {
        CFStringRef scheme = CFStringCreateWithSubstring(NULL, urlString, schemeRange);
        self.scheme = (__bridge NSString *)scheme;
        CFRelease(scheme);
        
        // For URLs which feature no slashes to indicate the path *before* a
        // ; ? or # mark, we need to coerce them into parsing
        if (schemeRange.location == 0)
        {
            if (!CFStringFindWithOptions(urlString,
                                         CFSTR(":/"),
                                         CFRangeMake(schemeRange.length, CFStringGetLength(urlString) - schemeRange.length),
                                         kCFCompareAnchored,
                                         NULL))
            {
                NSMutableString *fudgedString = [(__bridge NSString *)urlString mutableCopy];
                [fudgedString insertString:@"/"
                                   atIndex:(schemeRange.length + 1)];   // after the colon
                
                aUrl = [NSURL URLWithString:fudgedString];
                KCRelease(fudgedString);
                urlString = CFURLGetString((CFURLRef)aUrl);
                
                fudgedParsing = YES;
            }
        }
    }
    
    // Avoid CFURLCopyUserName as it removes escapes
    CFRange userRange = CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentUser, NULL);
    if (userRange.location != kCFNotFound)
    {
        CFStringRef user = CFStringCreateWithSubstring(NULL, urlString, userRange);
        self.percentEncodedUser = (__bridge NSString *)user;
        CFRelease(user);
    }
    
    // Avoid CFURLCopyPassword as it removes escapes
    CFRange passwordRange = CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentPassword, NULL);
    if (passwordRange.location != kCFNotFound)
    {
        CFStringRef password = CFStringCreateWithSubstring(NULL, urlString, passwordRange);
        self.percentEncodedPassword = (__bridge NSString *)password;
        CFRelease(password);
    }
    
    
    // Avoid CFURLCopyHostName as it removes escapes
    CFRange hostRange = CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentHost, NULL);
    if (hostRange.location != kCFNotFound)
    {
        CFStringRef host = CFStringCreateWithSubstring(NULL, urlString, hostRange);
        self.percentEncodedHost = (__bridge NSString *)host;
        CFRelease(host);
    }
    
    // Need to represent the presence of a host whenever the URL starts scheme://
    // Manually searching is the best I've found so far
    else if (schemeRange.location == 0)
    {
        if (CFStringFindWithOptions(urlString,
                                    CFSTR("://"),
                                    CFRangeMake(schemeRange.length, CFStringGetLength(urlString) - schemeRange.length),
                                    kCFCompareAnchored,
                                    NULL))
        {
            self.percentEncodedHost = @"";
        }
    }
    
    
    SInt32 port = CFURLGetPortNumber((CFURLRef)aUrl);
    if (port >= 0) self.port = @(port);
    
    
    // Account for parameter. NS/CFURL treat it as distinct, but NSURLComponents rolls it into the path
    CFRange pathRange = CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentPath, NULL);
    
    CFRange parameterRange;
    CFURLGetByteRangeForComponent((CFURLRef)aUrl, kCFURLComponentParameterString, &parameterRange);
    
    if (pathRange.location != kCFNotFound || (parameterRange.location != kCFNotFound && parameterRange.length > 0))
    {
        if (pathRange.location == kCFNotFound)
        {
            pathRange = parameterRange;
        }
        else if (parameterRange.length > 0)
        {
            pathRange.length += parameterRange.length;
        }
        
        if (fudgedParsing)
        {
            pathRange.location++; pathRange.length--;
        }
        
        CFStringRef path = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)aUrl), pathRange);
        self.percentEncodedPath = (__bridge NSString *)path;
        self.percentEncodedPath = [KCUtilURI removeDotSegments:self.percentEncodedPath];
        CFRelease(path);
    }
    
    CFStringRef query = CFURLCopyQueryString((CFURLRef)aUrl, NULL);
    if (query)
    {
        self.percentEncodedQuery = (__bridge NSString *)query;
        CFRelease(query);
    }
    
    CFStringRef fragment = CFURLCopyFragment((CFURLRef)aUrl, NULL);
    if (fragment)
    {
        self.percentEncodedFragment = (__bridge NSString *)fragment;
        CFRelease(fragment);
    }
    
    return self;
}

+ (id)componentsWithURL:(NSURL *)aUrl resolvingAgainstBaseURL:(BOOL)aIsResolve;
{
    id components = [[self alloc] initWithURL:aUrl resolvingAgainstBaseURL:aIsResolve];
    KCAutorelease(components);
    return components;
}

- (id)initWithString:(NSString *)aURLString;
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

+ (id)componentsWithString:(NSString *)aURLString;
{
    id components = [[self alloc] initWithString:aURLString];
    KCAutorelease(components);
    return components;
}

- (void)dealloc;
{
    KCRelease(m_scheme);
    KCRelease(m_user);
    KCRelease(m_password);
    KCRelease(m_host);
    KCRelease(m_port);
    KCRelease(m_path);
    KCRelease(m_query);
    KCRelease(m_fragment);

    KCDealloc(super);
}

#pragma mark Generating a URL

- (NSURL *)URL;
{
    return [self URLRelativeToURL:nil];
}

- (NSURL *)URLRelativeToURL:(NSURL *)aBaseURL;
{
    NSString *user = self.percentEncodedUser;
    NSString *password = self.percentEncodedPassword;
    NSString *host = self.percentEncodedHost;
    NSNumber *port = self.port;
    NSString *path = self.percentEncodedPath;
    
    BOOL hasAuthorityComponent = (user || password || host || port);
    
    // If the KCURIComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string.
    if (hasAuthorityComponent &&
        !(path.length == 0 || [path isAbsolutePath]))
    {
        return nil;
    }
    
    // If the KCURIComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//".
    if (!hasAuthorityComponent && [path hasPrefix:@"//"])
    {
        return nil;
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    
    NSString *scheme = self.scheme;
    if (scheme)
    {
        [string appendString:scheme];
        [string appendString:@":"];
        [string appendString:@"//"];
    }
    
//    if (hasAuthorityComponent) [string appendString:@"//"];
    
    if (user) [string appendString:user];
    
    if (password)
    {
        [string appendString:@":"];
        [string appendString:password];
    }
    
    if (user || password) [string appendString:@"@"];
    
    if (host)
    {
        [string appendString:host];
    }
    
    if (port)
    {
        [string appendFormat:@":%u", port.unsignedIntValue];
    }
    
    if (path)
    {
        [string appendString:path];
    }
    
    NSString *query = self.percentEncodedQuery;
    if (query)
    {
        [string appendString:@"?"];
        [string appendString:query];
    }
    
    NSString *fragment = self.percentEncodedFragment;
    if (fragment)
    {
        [string appendString:@"#"];
        [string appendString:fragment];
    }
    
    NSURL *result = [NSURL URLWithString:string relativeToURL:aBaseURL];
    KCRelease(string);
    return result;
}

#pragma mark Components

@synthesize scheme = m_scheme;
- (void)setScheme:(NSString *)scheme;
{
    if (scheme)
    {
        NSCharacterSet *legalCharacters = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."];
        
        if ([scheme rangeOfCharacterFromSet:legalCharacters.invertedSet].location != NSNotFound)
        {
            [NSException raise:NSInvalidArgumentException format:@"invalid characters in scheme"];
        }
    }
    
    scheme = [scheme copy];
    KCRelease(m_scheme);
    m_scheme = scheme;
}

@synthesize percentEncodedUser = m_user;
- (NSString *)user;
{
    return [self.percentEncodedUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setUser:(NSString *)user;
{
    if (!user)
    {
        self.percentEncodedUser = user;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)user, NULL, CFSTR(":@/?#"), kCFStringEncodingUTF8);
    // : signifies the start of the password, so must be escaped
    // @ signifies the end of the user/password, so must be escaped
    // / ? # I reckon technically should be fine since they're before the @ symbol, but NSURLComponents seems to be cautious here, and understandably so
    
    self.percentEncodedUser = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedPassword = m_password;
- (NSString *)password;
{
    return [self.percentEncodedPassword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setPassword:(NSString *)password;
{
    if (!password)
    {
        self.percentEncodedPassword = password;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ signifies the end of the user/password, so must be escaped
    // : / ? # I reckon technically should be fine since they're before the @ symbol, but NSURLComponents seems to be cautious here, and understandably so
    
    self.percentEncodedPassword = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedHost = m_host;
- (NSString *)host;
{
    // Treat empty host specially. It signifies the host in URLs like file:///path
    // nil for practical usage from -host, but a marker internally to differentiate
    // from file:/path
    NSString *host = self.percentEncodedHost;
    if (host.length == 0) return nil;
    
    return [host stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setHost:(NSString *)host;
{
    if (!host)
    {
        self.percentEncodedHost = host;
        return;
    }
    
    NSRange startBracket = [host rangeOfString:@"[" options:NSAnchoredSearch];
    if (startBracket.location != NSNotFound)
    {
        NSRange endBracket = [host rangeOfString:@"]" options:NSAnchoredSearch|NSBackwardsSearch];
        if (endBracket.location != NSNotFound)
        {
            host = [host substringWithRange:NSMakeRange(startBracket.length, host.length - endBracket.length - startBracket.length)];
            
            CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, CFSTR("@/?#"), kCFStringEncodingUTF8);
            // @ must be escaped so as not to confuse as a username
            // Don't escape : as it's within a host literal, and likely part of an IPv6 address
            // / ? and # must be escaped so as not to indicate start of path, query or fragment
            
            NSString *encoded = [NSString stringWithFormat:@"[%@]", escaped];
            
            self.percentEncodedHost = encoded;
            CFRelease(escaped);
            return;
        }
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ must be escaped so as not to confuse as a username
    // : must be escaped too to avoid confusion with port
    // / ? and # must be escaped so as not to indicate start of path, query or fragment
    
    self.percentEncodedHost = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

@synthesize port = m_port;
- (void)setPort:(NSNumber *)port;
{
    if (port.integerValue < 0) [NSException raise:NSInvalidArgumentException format:@"Invalid port: %@; can't be negative", port];
    
    port = [port copy];
    KCRelease(m_port);
    m_port = port;
}

@synthesize percentEncodedPath = m_path;
- (NSString *)path;
{
    // Same treatment as -host
    NSString *path = self.percentEncodedPath;
    if (path.length == 0) return nil;
    
    if (![path kc_startsWithChar:'/'])
    {
        path = [NSString stringWithFormat:@"/%@", path];
    }
    
    return [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setPath:(NSString *)path;
{
    if (!path)
    {
        self.percentEncodedPath = path;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, NULL, CFSTR(":;?#"), kCFStringEncodingUTF8);
    // : doesn't *need* to be escaped if the path is part of a complete URL, but it does if the generated URL is scheme-less. Seems safest to always escape it, and NSURLComponents does so too
    // ; ? and # all need to be escape to avoid confusion with parameter, query and fragment
    
    self.percentEncodedPath = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedQuery = m_query;
- (void)setPercentEncodedQuery:(NSString *)percentEncodedQuery;
{
    // FIXME: Check the query is valid
    percentEncodedQuery = [percentEncodedQuery copy];
    KCRelease(m_query);
    m_query = percentEncodedQuery;
}
- (NSString *)query;
{
    return [self.percentEncodedQuery stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setQuery:(NSString *)query;
{
    if (!query)
    {
        self.percentEncodedQuery = query;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)query, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedQuery = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedFragment = m_fragment;
- (NSString *)fragment;
{
    return [self.percentEncodedFragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setFragment:(NSString *)aFragment;
{
    if (!aFragment)
    {
        self.percentEncodedFragment = aFragment;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aFragment, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedFragment = (__bridge NSString *)escaped;
    CFRelease(escaped);
}

#pragma mark Equality Testing

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:[KCURIComponents class]]) return NO;
    
    NSString *myScheme = self.scheme;
    NSString *otherScheme = [object scheme];
    if (myScheme != otherScheme && ![myScheme isEqualToString:otherScheme]) return NO;
    
    NSString *myUser = self.percentEncodedUser;
    NSString *otherUser = [object percentEncodedUser];
    if (myUser != otherUser && ![myUser isEqualToString:otherUser]) return NO;
    
    NSString *myPassword = self.percentEncodedPassword;
    NSString *otherPassword = [object percentEncodedPassword];
    if (myPassword != otherPassword && ![myPassword isEqualToString:otherPassword]) return NO;
    
    NSString *myHost = self.percentEncodedHost;
    NSString *otherHost = [object percentEncodedHost];
    if (myHost != otherHost && ![myHost isEqualToString:otherHost]) return NO;
    
    NSNumber *myPort = self.port;
    NSNumber *otherPort = [(KCURIComponents *)object port];
    if (myPort != otherPort && ![myPort isEqualToNumber:otherPort]) return NO;
    
    NSString *myPath = self.percentEncodedPath;
    NSString *otherPath = [object percentEncodedPath];
    if (myPath != otherPath && ![myPath isEqualToString:otherPath]) return NO;
    
    NSString *myQuery = self.percentEncodedQuery;
    NSString *otherQuery = [object percentEncodedQuery];
    if (myQuery != otherQuery && ![myQuery isEqualToString:otherQuery]) return NO;
    
    NSString *myFragment = self.percentEncodedFragment;
    NSString *otherFragment = [object percentEncodedFragment];
    if (myFragment != otherFragment && ![myFragment isEqualToString:otherFragment]) return NO;
    
    return YES;
}

- (NSUInteger)hash;
{
    // This could definitely be a better algorithm!
    return self.scheme.hash + self.percentEncodedUser.hash + self.percentEncodedPassword.hash + self.percentEncodedPassword.hash + self.percentEncodedHost.hash + self.port.hash + self.percentEncodedPath.hash + self.percentEncodedQuery.hash + self.percentEncodedFragment.hash;
}

- (NSArray*)createPathSegments
{
    NSArray *segments = [m_path componentsSeparatedByString: @"/"];
    return segments;
}


- (NSArray*)getPathSegments
{
    if (!m_pathSegments)
        m_pathSegments = [self createPathSegments];
    return m_pathSegments;
}

- (NSString*)getLastPathSegment
{
    NSString* segment = nil;
    NSArray* list = [self getPathSegments];
    if(list && list.count > 0)
    {
        segment = [list objectAtIndex:list.count-1];
    }
    return segment;
}


#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    KCURIComponents *result = [[KCURIComponents alloc] init];
    
    result.scheme = self.scheme;
    result.percentEncodedUser = self.percentEncodedUser;
    result.percentEncodedPassword = self.percentEncodedPassword;
    result.percentEncodedHost = self.percentEncodedHost;
    result.port = self.port;
    result.percentEncodedPath = self.percentEncodedPath;
    result.percentEncodedQuery = self.percentEncodedQuery;
    result.percentEncodedFragment = self.percentEncodedFragment;
    
    return result;
}

#pragma mark Debugging

- (NSString *)description;
{
    return [[super description] stringByAppendingFormat:
            @" {scheme = %@, user = %@, password = %@, host = %@, port = %@, path = %@, query = %@, fragment = %@}",
            self.scheme,
            self.percentEncodedUser,
            self.percentEncodedPassword,
            self.percentEncodedHost,
            self.port,
            self.percentEncodedPath,
            self.percentEncodedQuery,
            self.percentEncodedFragment];
}

@end
