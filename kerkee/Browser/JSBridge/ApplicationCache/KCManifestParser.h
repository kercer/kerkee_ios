//
//  KCManifestParser.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCManifestObject.h"

@interface KCManifestParser : NSObject
{
}

-(KCManifestObject*)parser:(NSString*)aManifest;
-(KCManifestObject*)parserData:(NSData *)aManifest;

-(NSString*)getCommentValueForKey:(NSString*)aKey;
-(NSArray*)getCacheTokens;
-(NSString*)getManifestContent;


@end
