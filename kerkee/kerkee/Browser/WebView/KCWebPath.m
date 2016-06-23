//
//  KCWebPath.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCWebPath.h"
#import "KCBaseDefine.h"
#import <KCFile.h>

#define kDefaultRootPath ([NSHomeDirectory() stringByAppendingPathComponent:@"Documents"])
#define kDefaultResRootPath ([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"])

@interface KCWebPath ()
{
    NSString* m_rootPath;
}

@end

@implementation KCWebPath


- (id)init
{
    if(self = [super init])
    {
        m_rootPath = kDefaultRootPath;
    }
    return self;
}


- (void)dealloc
{
    KCDealloc(super);
}


//@ aPath is webview root path,if path if null, use default root path
- (void)setRootPath:(NSString*)aPath
{
    m_rootPath = aPath;
}


- (NSString*)getRootPath
{
    if (m_rootPath == nil)
    {
        m_rootPath = kDefaultRootPath;
    }
    
    return m_rootPath;
}

-(NSString*)getResRootPath
{
    KCFile* file = [[KCFile alloc] initWithPath:[self getRootPath] name:@"html"];
    
    return file.getAbsolutePath;
    
}



@end
