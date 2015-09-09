//
//  KCManifestParser.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface KCManifestParser : NSObject
{

}

-(void)parser:(NSString*)aManifest;
-(NSString*)getCommentValueForKey:(NSString*)aKey;
-(NSArray*)getCacheTokens;
-(NSString*)getManifestContent;

@end
