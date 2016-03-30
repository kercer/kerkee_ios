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
//root dir is Document
+ (NSString *)dataPath:(NSString *)fileName;

+ (BOOL) isExist:(NSString*)aPath;

//delete the specified file or folder
+ (void) deleteFile:(NSString*)filePath;
//get url dir
+ (NSString *) getRemoteDirUrlWithUrl:(NSString *)url;
//get the relative path
+ (NSString *) getRelativePathWithUrl:(NSString *)url;
+ (NSString *) getFileNameWithUrl:(NSString*)url;
+ (NSString*) getFilenameWithPath:(NSString*)aPath;

+ (NSString *) appendToPath:(NSString *)dirPath FileName:(NSString *)fileName;
+ (NSString *) appendToUrl:(NSString *)url FileName:(NSString *)fileName;







@end
