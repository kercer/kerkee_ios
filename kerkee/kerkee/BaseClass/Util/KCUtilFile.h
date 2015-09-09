//
//  KCUtilFile.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KCUtilFile : NSObject

+ (NSString *)getDocumentPath;
//根目录为Document
+ (NSString *)dataPath:(NSString *)fileName;

+ (BOOL) isExist:(NSString*)aPath;

//删除指定文件或文件夹
+ (void) deleteFile:(NSString*)filePath;
//获取url目录
+ (NSString *) getRemoteDirUrlWithUrl:(NSString *)url;
//获取相对路径
+ (NSString *) getRelativePathWithUrl:(NSString *)url;
+ (NSString *) getFileNameWithUrl:(NSString*)url;
+ (NSString*) getFilenameWithPath:(NSString*)aPath;
//本地皆可以使用
+ (NSString *) appendToPath:(NSString *)dirPath FileName:(NSString *)fileName;
+ (NSString *) appendToUrl:(NSString *)url FileName:(NSString *)fileName;

+ (NSArray*)getFileList:(NSString*)dirPath IsContainSub:(BOOL)isContainSub;
+ (NSArray*)getFilePathList:(NSString*)dirPath IsContainSub:(BOOL)isContainSub;
+ (NSString*)getFileType:(NSString*)filePath;
+ (NSDate*)getFileCreateDate:(NSString*)filePath;
+ (NSDate*)getFileModifyDate:(NSString*)filePath;
+ (unsigned long long) fileSizeAtPath:(NSString*) filePath;
+ (unsigned long long) folderSizeAtPath:(NSString*) folderPath;

+(unsigned long long) freeDiskSpace;
+(unsigned long long) getTotalDiskSpaceInBytes;

+(BOOL)moveFileFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
+(void)moveFileFromPathAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock;
+(BOOL)copyFileFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
+(void)copyFileFromPathAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock;


+(NSMutableData*)readBundleWithFileName:(NSString *)aFilename type:(NSString *)aFiletype;

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;



@end
