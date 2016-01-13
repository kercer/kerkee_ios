//
//  KCUtilFile.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilFile.h"
#import "KCBaseDefine.h"
#import "KCTaskQueue.h"

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

//根目录为Document
+ (NSString *)dataPath:(NSString *)fileName
{
    NSString *documentsDirectory = [KCUtilFile getDocumentPath];
//    for (NSUInteger i = 0; ;)
//    {
//        unichar chTemp = [fileName characterAtIndex:i];
//        if (chTemp == '.')
//        {
//            fileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//            continue;
//        }
//        break;
//    }
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

//获取相对路径
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

//本地可以使用
+ (NSString *) appendToPath:(NSString *)dirPath FileName:(NSString *)fileName
{
    if(!fileName || fileName.length==0) return dirPath;
//    for (NSUInteger i = 0; ;)
//    {
//        unichar chTemp = [fileName characterAtIndex:i];
//        if (chTemp == '.')
//        {
//            fileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//            continue;
//        }
//        break;
//    }
    return [dirPath stringByAppendingPathComponent:fileName];
}

+ (NSString *) appendToUrl:(NSString *)url FileName:(NSString *)fileName
{
    if(!fileName) return url;
//    for (NSUInteger i = 0; ;)
//    {
//        unichar chTemp = [fileName characterAtIndex:i];
//        if (chTemp == '.' || chTemp == '/')
//        {
//            fileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//            continue;
//        }
//        break;
//    }
    
    NSURL* remoteUrl = [NSURL URLWithString:url];
    KCLog(@"~~~~~~~~~~~~~~~~~~~~~ %@, %@", remoteUrl, fileName);
    return [[remoteUrl URLByAppendingPathComponent:fileName] absoluteString];
    
}

+ (NSArray*)getFileList:(NSString*)dirPath IsContainSub:(BOOL)isContainSub
{
    //    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    //    KCAutorelease(fileList);
    //	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
    //									  enumeratorAtPath:dirPath];
    //	NSString *pname;
    //	while (pname = [direnum nextObject])
    //	{
    //		[fileList addObject:pname];
    //	}
    
    NSArray* fileList = nil;
    if (isContainSub) {
        fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dirPath error:nil];
    }
    else
    {
        fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    }
    
    KCLog(@"%@", fileList);
    
    return fileList;
}

+ (NSArray*)getFilePathList:(NSString*)dirPath IsContainSub:(BOOL)isContainSub
{
    NSMutableArray *filePathList = [[NSMutableArray alloc] init];
    KCAutorelease(filePathList); 
    
    NSArray* fileList = [KCUtilFile getFileList:dirPath IsContainSub:isContainSub];
    for (NSString* fileName in fileList) {
        NSString* filePath = [KCUtilFile appendToPath:dirPath FileName:fileName];
        [filePathList addObject:filePath];
    }
    return filePathList;
}

+(NSString*) getFileType:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [[fileManager attributesOfItemAtPath:filePath error:nil] fileType];
}

+ (NSDate*)getFileCreateDate:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [[fileManager attributesOfItemAtPath:filePath error:nil] fileCreationDate];
}

+ (NSDate*)getFileModifyDate:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [[fileManager attributesOfItemAtPath:filePath error:nil] fileModificationDate];
}

+ (unsigned long long) fileSizeAtPath:(NSString*) filePath
{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
    {
        return st.st_size;
    }
    return 0;
}


+ (unsigned long long) folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

+(unsigned long long) freeDiskSpace
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/", &buf) >= 0)
    {
        freespace = (unsigned long long)buf.f_bsize * buf.f_bfree;
    }
    
    return freespace;
}

+(unsigned long long) getTotalDiskSpaceInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] UTF8String], &tStats);
    unsigned long long totalSpace = (unsigned long long)(tStats.f_blocks * tStats.f_bsize);
    
    return totalSpace;
}

+(BOOL)moveFileFromPath:(NSString*)fromPath toPath:(NSString*)toPath
{
    if(nil == fromPath || 0 == [fromPath length])
		return NO;
	if(nil == toPath || 0 == [toPath length])
		return NO;
	
	if(nil != fromPath && nil != toPath)
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:fromPath])
		{
			NSError * err = nil;
			
			if(![[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&err])
				return NO;
		}
		else
			return YES;
		
	}
	else
		return NO;
	
	return YES;

}

+(void)moveFileFromPathAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    BOOL isSucceed = [self moveFileFromPath:fromPath toPath:toPath];
    FOREGROUND_BEGIN
    if (aBlock)
        aBlock(isSucceed);
    FOREGROUND_COMMIT
    
    BACKGROUND_GLOBAL_COMMIT
}


+(BOOL)copyFileFromPath:(NSString*)fromPath toPath:(NSString*)toPath
{
    if(nil == fromPath || 0 == [fromPath length])
		return NO;
	if(nil == toPath || 0 == [toPath length])
		return NO;
	
	if(nil != fromPath && nil != toPath)
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:fromPath])
		{
			NSError * err = nil;
			
			if(![[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&err])
				return NO;
		}
		else
			return YES;
		
	}
	else
		return NO;
	
	return YES;
}

+(void)copyFileFromPathAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    BOOL isSucceed = [self copyFileFromPath:fromPath toPath:toPath];
    FOREGROUND_BEGIN
    if (aBlock)
        aBlock(isSucceed);
    FOREGROUND_COMMIT
    
    BACKGROUND_GLOBAL_COMMIT

}


+(NSMutableData*) readBundleWithFileName:(NSString *)aFilename type:(NSString *)aFiletype
{
	
	if(nil == aFilename)
		return nil;
	
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [bundle pathForResource:aFilename ofType:aFiletype];
    
	if(nil == path)
		return nil;
	
	NSMutableData * bundleData = (NSMutableData*)[[NSFileManager defaultManager] contentsAtPath:path];
	if(nil == bundleData)
		return nil;
	
	return bundleData;
}


+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
        return NO;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.1) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    } else {
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

@end
