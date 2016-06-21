//
//  KCArchiver.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface KCArchiver : NSObject

#pragma mark - API

+ (NSData*)archive:(NSObject *)aObj;
+ (NSObject*)unarchive:(NSData *)aData;

+ (BOOL)archiveFile:(id <NSCoding>)aRootObject forKey:(NSString*)aKey;
+ (id)unarchiveFile:(NSString*)aKey;
+ (id)unarchiveFile:(NSString*)aKey defaultObject:(id(^)())aDefaultObject;
+ (id)unarchiveFile:(NSString*)aKey failure:(void(^)())failure;

+ (BOOL)removeArchiveFile:(NSString*)aKey;
+ (BOOL)archiveFileExists:(NSString*)aKey;

+ (NSString*)path;

@end
