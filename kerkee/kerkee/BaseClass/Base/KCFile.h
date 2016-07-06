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
 * The system-dependent character used to separate components in filenames ('/').
 * Use of this (rather than hard-coding '/') helps portability to other operating systems.
 *
 * <p>This field is initialized from the system property "file.separator".
 * Later changes to that property will have no effect on this field or this class.
 */
+ (char)separatorChar;

/**
 The system-dependent string used to separate components in filenames ('/').
 */
+ (NSString*)separator;

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
 * Returns the name of the file or directory represented by this file.
 *
 * @return this file's name or an empty string if there is no name part in
 *         the file's path.
 */
- (NSString*)getName;

/**
 * Returns the pathname of the parent of this file. This is the path up to
 * but not including the last name. nil is returned if there is no parent.
 *
 * @return this file's parent pathname or nil.
 */
- (NSString*)getParent;

/**
 * Returns a new file made from the pathname of the parent of this file.
 * This is the path up to but not including the last name. nil is
 * returned when there is no parent.
 *
 * @return a new file representing this file's parent or nil.
 */
- (KCFile*)getParentFile;

/**
 * Returns the path of this file.
 */
- (NSString*)getPath;

/**
 * Returns an integer hash code for the receiver. Any two objects for which
 * equals returns true must return the same hash code.
 *
 * @return this files's hash value.
 * @see #equals
 */
- (NSUInteger)hash;

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
 * Indicates if this file represents a <em>directory</em> on the
 * underlying file system.
 *
 * @return true if this file is a directory, false
 *         otherwise.
 */
- (BOOL)isDir;

/**
 * Indicates if this file represents a <em>file</em> on the underlying
 * file system.
 *
 * @return true if this file is a file, false otherwise.
 */
- (BOOL)isFile;

/*
 * Creates the directory named by this file, creating missing parent
 * directories if necessary.
 */
- (BOOL)mkdirs;

/**
 * Creates a new, empty file on the file system according to the path
 * information stored in this file. This method returns true if it creates
 * a file, false if the file already existed. Note that it returns false
 * even if the file is not a file (because it's a directory, say).
 */
- (BOOL)createNewFile;

/**
 * Renames this file to  aNewPath. This operation is supported for both
 * files and directories.
 */
- (BOOL)renameTo:(KCFile*)aNewPath;

/**
 * Returns a string containing a concise, human-readable description of this
 * file.
 */
- (NSString*)description;
- (NSString*)toString;

/**
 * Returns a Uniform Resource Identifier for this file. The URI is system
 * dependent and may not be transferable between different operating / file
 * systems.
 *
 * @return an KCURI for this file.
 */
- (KCURI*)toURI;

/**
 * Returns a Uniform Resource Locator for this file. The URL is system
 * dependent and may not be transferable between different operating / file
 * systems.
 */
- (NSURL*)toURL;

@end
