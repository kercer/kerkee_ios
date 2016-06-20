//
//  KCFile.m
//  kerkee
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCFile.h"
#import "string.h"
#import "KCFileManager.h"
#import "KCBaseDefine.h"

#define kSeparatorChar '/'

@interface KCFile ()
{
    NSString* m_path;
}

@end


// Removes duplicate adjacent slashes and any trailing slash.
static NSString* fixSlashes(NSString* origPath)
{
    if (!origPath) return nil;
    // Remove duplicate adjacent slashes.
    bool lastWasSlash = false;
    const char* newOrigPath = origPath.UTF8String;
//    const char* newOrigPath = [origPath cStringUsingEncoding:NSUTF8StringEncoding];//0x80000632
    if (!newOrigPath) return nil;
    
    int length = (int)strlen(newOrigPath);
    char* newPath = malloc((length+1)*sizeof(char));
    memset(newPath, 0, (length+1)*sizeof(char));
    int newLength = 0;
    for (int i = 0; i < length; ++i)
    {
        char ch = newOrigPath[i];
        if (ch == '/')
        {
            if (!lastWasSlash)
            {
                newPath[newLength++] = kSeparatorChar;
                lastWasSlash = true;
            }
        }
        else
        {
            newPath[newLength++] = ch;
            lastWasSlash = false;
        }
    }
    // Remove any trailing slash (unless this is the root of the file system).
    if (lastWasSlash && newLength > 1)
    {
        newLength--;
    }
    
    NSString *newPathString = [NSString stringWithCString:newPath encoding:NSUTF8StringEncoding];
    
    if (newPath)
    {
        free(newPath);
        newPath = NULL;
    }
    
    // Reuse the original string if possible.
    return (newLength != length) ? newPathString : origPath;
}


// Joins two path components, adding a separator only if necessary.
static NSString* join(NSString* prefix, NSString* suffix)
{
//    if (!prefix) prefix = @"";
//    if (!suffix) suffix = @"";
    int prefixLength = (int)prefix.length;
    bool haveSlash = (prefixLength > 0 && [prefix characterAtIndex:prefixLength - 1] == kSeparatorChar);
    if (!haveSlash)
    {
        haveSlash = (suffix.length > 0 && [suffix characterAtIndex:0] == kSeparatorChar);
    }
    return haveSlash ? [NSString stringWithFormat:@"%@%@", prefix, suffix] : [NSString stringWithFormat:@"%@%c%@", prefix, kSeparatorChar,suffix];
}

@implementation KCFile

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (id)initWithPath:(NSString*)aPath
{
    if (self = [super init])
    {
        m_path = fixSlashes(aPath);
    }
    return self;
}

- (id)initWithPath:(NSString*)aDirPath name:(NSString*)aName
{
    if (self = [super init])
    {
        if (aDirPath == NULL || aDirPath.length == 0)
        {
            m_path = fixSlashes(aName);
        }
        else if (aName.length == 0)
        {
            m_path = fixSlashes(aDirPath);
        }
        else
        {
            m_path = fixSlashes(join(aDirPath, aName));
        }
    }
    return self;
}

- (id)initWithFile:(KCFile*)aDirFile name:(NSString*)aName
{
    self = [self initWithPath:(aDirFile ? aDirFile.getPath : nil) name:aName];
    
    return self;
}

- (id)initWitURI:(KCURI*)aURI
{
    if (aURI)
    {
        [self checkURI:aURI];
        m_path = fixSlashes(aURI.components.path);
    }
    
    return self;
}


- (void)checkURI:(KCURI*)aURI
{
    NSAssert(aURI.isAbsolute, @"URI is not absolute:");
    NSAssert([@"file" isEqualToString:aURI.components.scheme], @"Expected file scheme in URI");
    NSAssert(aURI.components.path != NULL && aURI.components.path.length>0, @"Expected non-empty path in URI");
    NSAssert(aURI.components.user == NULL && aURI.components.password == NULL, @"Found authority in URI");
    NSAssert(aURI.components.query == NULL, @"Found query in URI");
    NSAssert(aURI.components.fragment == NULL, @"Found fragment in URI");
}


- (NSString*)getPath
{
    return m_path;
}

- (BOOL)isAbsolute
{
    if (!m_path) return false;
    return [KCFileManager isAbsolute:m_path];
}

- (BOOL)canExecute
{
    if (!m_path) return false;
    return [KCFileManager isExecutable:m_path];
}

- (BOOL)canRead
{
    if (!m_path) return false;
    return [KCFileManager isReadable:m_path];
}

- (BOOL)canWrite
{
    if (!m_path) return false;
    return [KCFileManager isWritable:m_path];
}

- (BOOL)remove
{
    if (!m_path) return false;
    NSError* error = nil;
    return [KCFileManager remove:m_path error:&error];
}

- (NSError*)removeItem
{
    if (!m_path) return false;
    NSError* error = nil;
    [KCFileManager remove:m_path error:&error];
    return error;
}

- (BOOL)equals:(id)aObj
{
    if (![aObj isKindOfClass:KCFile.class])
    {
        return false;
    }
    if (!m_path) return false;
    return [m_path isEqualToString:[(KCFile*)aObj getPath]];
}

- (BOOL)exists
{
    if (!m_path) return false;
    return [KCFileManager existsFast:m_path];
}

- (NSString*)getAbsolutePath
{
    if (!m_path) return nil;
    return [KCFileManager absolutePath:m_path];
}

- (KCFile*)getAbsoluteFile
{
    KCFile* file = [[KCFile alloc] initWithPath:[self getAbsolutePath]];
    KCAutorelease(file);
    return file;
}

- (KCURI*)toURI
{
    return nil;
}

@end
