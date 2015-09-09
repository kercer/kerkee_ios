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

+ (BOOL)archiveRootObject:(id <NSCoding>)aRootObject forKey:(NSString*)aKey;

+ (id)unarchiveObjectForKey:(NSString*)aKey;
+ (id)unarchiveObjectForKey:(NSString*)aKey defaultObject:(id(^)())aDefaultObject;
+ (id)unarchiveObjectForKey:(NSString*)aKey failure:(void(^)())failure;

+ (BOOL)removeArchiveForKey:(NSString*)aKey;
+ (BOOL)archiveExistsForKey:(NSString*)aKey;

+ (NSString*)path;

@end
