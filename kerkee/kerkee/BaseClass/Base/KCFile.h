//
//  KCFile.h
//  kerkee
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KCURI.h>

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
 * Constructs a new File using the path of the specified KCURI. uri
 * needs to be an absolute and hierarchical Unified Resource Identifier with
 * file scheme and non-empty path component, but with undefined authority,
 * query or fragment components.
 *
 * @param uri
 *            the Unified Resource Identifier that is used to construct this
 *            file.
 * @see #toURI
 */
- (id)initWitURI:(KCURI*)aURI;

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
 * Deletes this file. Directories must be empty before they will be deleted.
 *
 * Callers must check the return value.
 *
 * @return true if this file was deleted, false otherwise.
 */
- (BOOL)remove;
- (NSError*)removeItem;

/**
 * Compares aObj to this file and returns true if they
 * represent the <em>same</em> object using a path specific comparison.
 *
 * @param obj
 *            the object to compare this file with.
 * @return true if  aObj is the same as this object, false otherwise.
 */
- (BOOL)equals:(id)aObj;

/**
 * Returns a boolean indicating whether this file can be found on the
 * underlying file system.
 *
 * @return true if this file exists, false otherwise.
 */
- (BOOL)exists;

/**
 * Returns the absolute path of this file. An absolute path is a path that starts at a root
 * of the file system. On Android, there is only one root: /.
 */
- (NSString*)getAbsolutePath;

/**
 * Returns a new file constructed using the absolute path of this file.
 * Equivalent to create KCFile(getAbsolutePath()).
 */
- (KCFile*)getAbsoluteFile;


/**
 * Returns the path of this file.
 */
- (NSString*)getPath;

/**
 * Indicates if this file's pathname is absolute. Whether a pathname is
 * absolute is platform specific. On iOS & Android, absolute paths start with
 * the character '/'.
 *
 * @return true if this file's pathname is absolute,  false
 *         otherwise.
 * @see #getPath
 */
- (BOOL)isAbsolute;


/**
 * Returns a Uniform Resource Identifier for this file. The URI is system
 * dependent and may not be transferable between different operating / file
 * systems.
 *
 * @return an KCURI for this file.
 */
- (KCURI*)toURI;

@end
