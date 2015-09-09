//
//  KCManifestParser.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//




#import "KCManifestParser.h"
#import "KCBaseDefine.h"


@interface KCManifestParser()
{
    NSMutableArray* m_cacheTokens;
    NSMutableArray* m_commentTokens;
    
    NSMutableDictionary* m_commentDictionary;
    
    NSString* m_manifestContent;
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
        if (!m_cacheTokens)
        {
            m_cacheTokens = [[NSMutableArray alloc] init];
        }
        if(!m_commentTokens)
        {
            m_commentTokens = [[NSMutableArray alloc] init];
        }
        if (!m_commentDictionary)
        {
            m_commentDictionary = [[NSMutableDictionary alloc] init];
        }
        
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_cacheTokens);
    m_cacheTokens = nil;
    KCRelease(m_commentTokens);
    m_commentTokens = nil;
    KCRelease(m_commentDictionary);
    m_commentDictionary = nil;
    KCRelease(m_manifestContent);
    m_manifestContent = nil;
    KCDealloc(super);
}


-(void)parser:(NSString*)aManifest
{
    m_manifestContent = aManifest;
    KCRetain(m_manifestContent);
    NSArray *oldTokens = [aManifest componentsSeparatedByString: @"\n"];
    [self cleanToken:oldTokens];
}

-(void)cleanToken:(NSArray *)aOldTokens
{
    NSString *manifestToken = @"cache manifest";
	NSString *commentToken = @"#";
	NSString *networkToken = @"network:";
	NSString *cacheToken = @"cache:";
	NSString *fallbackToken = @"fallback:";
    KCManifestToken tokenMark = ENone;
    for (NSString *token in aOldTokens) {
        NSString* tokenTrim = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		BOOL isAdd= YES;
		if ([[tokenTrim lowercaseString] rangeOfString:manifestToken].location != NSNotFound)
        {
            isAdd = NO;
            tokenMark = EManifest;
        }
		if ([[tokenTrim lowercaseString] rangeOfString:commentToken].location != NSNotFound)
        {
            isAdd = YES;
            tokenMark = EComment;
        }
		if ([[tokenTrim lowercaseString] rangeOfString:networkToken].location != NSNotFound)
        {
            isAdd = NO;
            tokenMark = ENetwork;
        }
		if ([[tokenTrim lowercaseString] rangeOfString:cacheToken].location != NSNotFound)
        {
            isAdd = NO;
            tokenMark = ECache;
        }
		if ([[tokenTrim lowercaseString] rangeOfString:fallbackToken].location != NSNotFound)
        {
            isAdd = NO;
            tokenMark = EFallback;
        }
        
		if (isAdd && [tokenTrim length]>0)
        {
            switch (tokenMark) {
                case EComment:
                {
                    NSString* tempComment = [tokenTrim stringByReplacingOccurrencesOfString:commentToken withString:@""];
                    [m_commentTokens addObject:tempComment]; 
                    [self separatCommentAddToDic:tempComment];
                    break;
                }
                case ECache:
                    [m_cacheTokens addObject:tokenTrim];
                    break;
                default:
                    break;
            }
        }
	}
}

-(void) separatCommentAddToDic:(NSString*)aComment
{
    NSArray *oldTokens = [aComment componentsSeparatedByString: @":"];
    if ([oldTokens count] == 2)
    {
        NSString* strKey = [oldTokens objectAtIndex:0];
        NSString* strValue = [oldTokens objectAtIndex:1];
        
        NSString* strKeyTrim = [strKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* strValueTrim = [strValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [m_commentDictionary setObject:strValueTrim forKey:strKeyTrim];
    }
}

-(NSString*)getCommentValueForKey:(NSString*)aKey
{
    return [m_commentDictionary objectForKey:aKey];
}

-(NSArray*)getCacheTokens
{
    return m_cacheTokens;
}

-(NSString*)getManifestContent
{
    return m_manifestContent;
}


@end
