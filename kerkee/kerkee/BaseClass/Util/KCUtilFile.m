//
//  KCUtilFile.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilFile.h"
#import "KCBaseDefine.h"


#include "sys/stat.h"
#include <sys/xattr.h>

#include <sys/param.h>
#include <sys/mount.h>

@implementation KCUtilFile

+ (NSString *)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)dataPath:(NSString *)fileName
{
    NSString *documentsDirectory = [KCUtilFile getDocumentPath];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (BOOL) isExist:(NSString*)aPath
{
    if(aPath && aPath.length > 0)
    {
        return [[NSFileManager defaultManager] fileExistsAtPath:aPath];
    }
    
    return NO;
}

+ (void) deleteFile:(NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]) 
        {
            KCLog(@"删除文件成功");
        }
        else 
        {
            KCLog(@"删除文件失败");
        }
    }
}

+ (NSString *) getRemoteDirUrlWithUrl:(NSString *)url
{
    NSURL* remoteUrl = [NSURL URLWithString:url];
    
    return [[remoteUrl URLByDeletingLastPathComponent] absoluteString];
}


+ (NSString *) getRelativePathWithUrl:(NSString *)url
{
    NSURL* uri = [NSURL URLWithString:url];
    return [uri path];
}

+(NSString *) getFileNameWithUrl:(NSString*)url
{
    NSURL* uri = [NSURL URLWithString:url];
    return [uri lastPathComponent];
}

+ (NSString*) getFilenameWithPath:(NSString*)aPath
{
   return [aPath lastPathComponent];
}


+ (NSString *) appendToPath:(NSString *)dirPath FileName:(NSString *)fileName
{
    if(!fileName || fileName.length==0) return dirPath;
    return [dirPath stringByAppendingPathComponent:fileName];
}

+ (NSString *) appendToUrl:(NSString *)url FileName:(NSString *)fileName
{
    if(!fileName) return url;
    NSURL* remoteUrl = [NSURL URLWithString:url];
    KCLog(@"~~~~~~~~~~~~~~~~~~~~~ %@, %@", remoteUrl, fileName);
    return [[remoteUrl URLByAppendingPathComponent:fileName] absoluteString];
    
}



@end
