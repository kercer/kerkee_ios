//
//  KCManifestParser.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//




#import "KCManifestParser.h"
#import "KCBaseDefine.h"
#import "KCURI.h"
#import "KCString.h"
#import "KCUtilURI.h"

#define kComment_Version @"version"
#define kComment_List @"list"
#define kComment_RequiredVersion @"requiredversion"
#define kComment_Dek @"dek"
#define kComment_Extra @"extra"

#define kFileSeparator (@"/")

@interface KCManifestParser()
{
    NSMutableArray* m_cacheLines;
    
    NSMutableDictionary* m_commentDictionary;
    
    NSString* m_manifestContent; //manifest content
    
    KCManifestObject* m_manifestObject;
    
}

typedef enum
{
    ENone,
    EManifest = 1,
    EComment,
    ENetwork,
    ECache,
    EFallback
    
} KCManifestToken;


@end


@implementation KCManifestParser

- (id)init
{
    if(self = [super init])
    {
        m_cacheLines = [[NSMutableArray alloc] init];
        m_commentDictionary = [[NSMutableDictionary alloc] init];
        m_manifestObject = [[KCManifestObject alloc] init];
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_cacheLines);
    m_cacheLines = nil;
    KCRelease(m_commentDictionary);
    m_commentDictionary = nil;
    KCRelease(m_manifestContent);
    m_manifestContent = nil;
    if (m_manifestObject)
    {
        KCRelease(m_manifestObject);
        m_manifestObject = nil;
    }
    KCDealloc(super);
}

-(KCManifestObject*)parserData:(NSData *)aManifest
{
    NSString *strData = [[NSString alloc] initWithData:aManifest encoding:NSUTF8StringEncoding];
    if (strData)
    {
       return [self parser:strData];
    }
    return nil;
}

-(KCManifestObject*)parser:(NSString*)aManifest
{
    m_manifestContent = aManifest;
    KCRetain(m_manifestContent);
    NSArray *lines = [aManifest componentsSeparatedByString: @"\n"];
    [self scanLine:lines];
    
    return m_manifestObject;
}



-(void)scanLine:(NSArray *)aLines
{
    NSString *manifestToken = @"cachemanifest";
	char commentToken = '#';
	NSString *networkToken = @"network:";
	NSString *cacheToken = @"cache:";
	NSString *fallbackToken = @"fallback:";
    KCManifestToken tokenMark = ENone;
    for (NSString *line in aLines)
    {
        NSRange range;
        range.location = 0;
        range.length = line.length;
        NSString* tokenTrim = [line stringByReplacingOccurrencesOfString:@" +" withString:@"" options:NSRegularExpressionSearch range:range];
        if (tokenTrim.length == 0) continue;
        
        tokenTrim = [tokenTrim lowercaseString];

        
		BOOL isAdd= YES;
		if ([tokenTrim isEqualToString:manifestToken])
        {
            isAdd = NO;
            tokenMark = EManifest;
        }
		else if ([tokenTrim characterAtIndex:0] == commentToken)
        {
            isAdd = YES;
            tokenMark = EComment;
        }
		else if ([tokenTrim isEqualToString:networkToken])
        {
            isAdd = NO;
            tokenMark = ENetwork;
        }
		else if ([tokenTrim isEqualToString:cacheToken])
        {
            isAdd = NO;
            tokenMark = ECache;
        }
		else if ([tokenTrim isEqualToString:fallbackToken])
        {
            isAdd = NO;
            tokenMark = EFallback;
        }
        
		if (isAdd && [tokenTrim length]>0)
        {
            switch (tokenMark) {
                case EComment:
                {
                    NSString* tempComment = [tokenTrim substringFromIndex:1];
                    [self handleCommentLine:tempComment];
                    break;
                }
                case ECache:
                    [self handleCacheLine:tokenTrim];
                    break;
                default:
                    break;
            }
        }
	}
}

-(void) handleCommentLine:(NSString*)aCommentLine
{
    NSArray *oldTokens = [aCommentLine componentsSeparatedByString: @":"];
    if ([oldTokens count] == 2)
    {
        NSString* strKey = [oldTokens objectAtIndex:0];
        NSString* strValue = [oldTokens objectAtIndex:1];
        [m_commentDictionary setObject:strKey forKey:strValue];
        if ([strKey isEqualToString:kComment_Version])
        {
            m_manifestObject.mVersion = strValue;
        }
        else if([strKey isEqualToString:kComment_RequiredVersion])
        {
            m_manifestObject.mRequiredVersion = strValue;
        }
        else if([strKey isEqualToString:kComment_List])
        {
            NSArray* list = [strValue componentsSeparatedByString:@","];
            m_manifestObject.mSubManifests = list;
        }
        else if([strKey isEqualToString:kComment_Dek])
        {
            KCURI* uri = [KCURI parse:strValue];
            if (uri.components.scheme == nil)
            {
                NSString* relativePath = uri.components.path;
//                relativePath = [KCUtilURI removeDotSegments:relativePath];
                m_manifestObject.mDekRelativePath = relativePath;
            }
            else if(uri.components.scheme && uri.components.host)
            {
                m_manifestObject.mDownloadUrl = strValue;
            }
        }
        else if([strKey isEqualToString:kComment_Extra])
        {
            NSArray* list = [strValue componentsSeparatedByString:@","];
            m_manifestObject.mExtras = list;
        }
    }
}

-(void)handleCacheLine:(NSString*)aLine
{
    if (!aLine) return;
    if ([self isInExtra:aLine]) return;
    NSMutableArray* cacheList =(NSMutableArray*) m_manifestObject.mCacheList;
    NSMutableArray* cacheDirs = (NSMutableArray*) m_manifestObject.mCacheDirs;
    if (!cacheList)
    {
        cacheList = [[NSMutableArray alloc] init];
        m_manifestObject.mCacheList = cacheList;
    }
    if (!cacheDirs)
    {
        cacheDirs = [[NSMutableArray alloc] init];
        m_manifestObject.mCacheDirs = cacheDirs;
    }
    [cacheList addObject:aLine];
    
    NSString* dir = kFileSeparator;
    int index = [KCString lastIndexOfChar:'/' str:aLine];
    if (index >= 0)
    {
        dir = [aLine substringToIndex:index+1];
    }
    if (![self isInSubManifest:dir] || [dir isEqualToString:kFileSeparator])
    {
        if (![cacheDirs containsObject:dir])
            [cacheDirs addObject:dir];
    }
    
    [m_cacheLines addObject:aLine];
}

- (BOOL)isInExtra:(NSString*)aFileName
{
    if ( !aFileName ) return false;
    NSArray* list = m_manifestObject.mExtras;
    if (list)
    {
        for (int i = 0; i < list.count; ++i)
        {
            if ([aFileName containsString:[list objectAtIndex:i]])
                return true;
        }
    }
    return false;
}

- (BOOL)isInSubManifest:(NSString*)aDir
{
    if ( !aDir ) return false;
    NSArray* list = m_manifestObject.mSubManifests;
    if (list)
    {
        for (int i = 0; i < list.count; ++i)
        {
            if ([[list objectAtIndex:i] containsObject:aDir])
                return true;
        }
    }
    return false;
}

-(NSString*)getCommentValueForKey:(NSString*)aKey
{
    return [m_commentDictionary objectForKey:aKey];
}

-(NSArray*)getCacheTokens
{
    return m_cacheLines;
}

-(NSString*)getManifestContent
{
    return m_manifestContent;
}


@end
