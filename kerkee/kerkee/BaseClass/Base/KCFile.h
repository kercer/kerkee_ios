//
//  KCFile.h
//  kerkee
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCFile : NSObject

/**
 * Constructs a new file using the specified path.
 *
 * @param aPath
 *            the path to be used for the file.
 */
- (id)initWithPath:(NSString*)aPath;

/**
 * Constructs a new File using the specified directory path and file name,
 * placing a path separator between the two.
 *
 * @param aDirPath
 *            the path to the directory where the file is stored.
 * @param aName
 *            the file's name.
 */
- (id)initWithPath:(NSString*)aDirPath name:(NSString*)aName;

/**
 * Constructs a new file using the specified directory and name.
 *
 * @param aDirFile
 *            the directory where the file is stored.
 * @param aName
 *            the file's name.
 */
- (id)initWithFile:(KCFile*)aDirFile name:(NSString*)aName;

/**
 * Tests whether or not this process is allowed to execute this file.
 * Note that this is a best-effort result; the only way to be certain is
 * to actually attempt the operation.
 */
- (BOOL)canExecute;

/**
 * Indicates whether the current context is allowed to read from this file.
 *
 * @return true if this file can be read, false otherwise.
 */
- (BOOL)canRead;

/**
 * Indicates whether the current context is allowed to write to this file.
 *
 * @return true if this file can be written,  false otherwise.
 */
- (BOOL)canWrite;

/**
 * Returns the path of this file.
 */
- (NSString*)getPath;

@end
