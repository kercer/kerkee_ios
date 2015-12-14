

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@interface KCFileManager : NSObject

+(id)attribute:(NSString *)aPath forKey:(NSString *)aKey;
+(id)attribute:(NSString *)aPath forKey:(NSString *)aKey error:(NSError **)aError;

+(NSDictionary *)attributes:(NSString *)path;
+(NSDictionary *)attributes:(NSString *)path error:(NSError **)error;

#pragma mark -
#pragma mark copy

+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath;
+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;
+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark -
#pragma mark create

+(BOOL)createDirForFilePath:(NSString *)path;
+(BOOL)createDirForFilePath:(NSString *)path error:(NSError **)error;

+(BOOL)createDirForPath:(NSString *)path;
+(BOOL)createDirForPath:(NSString *)path error:(NSError **)error;

+(BOOL)createFile:(NSString *)path;
+(BOOL)createFile:(NSString *)path error:(NSError **)error;

+(BOOL)createFile:(NSString *)path overwrite:(BOOL)overwrite;
+(BOOL)createFile:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error;

+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content;
+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content error:(NSError **)error;

+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite;
+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;

+(NSDate *)creationDate:(NSString *)path;
+(NSDate *)creationDate:(NSString *)path error:(NSError **)error;

+(BOOL)emptyCachesDir;
+(BOOL)emptyTemporaryDir;

+(BOOL)exists:(NSString *)path;

+(BOOL)isDir:(NSString *)path;
+(BOOL)isDir:(NSString *)path error:(NSError **)error;

+(BOOL)isEmpty:(NSString *)path;
+(BOOL)isEmpty:(NSString *)path error:(NSError **)error;

+(BOOL)isFile:(NSString *)path;
+(BOOL)isFile:(NSString *)path error:(NSError **)error;

+(BOOL)isExecutable:(NSString *)path;
+(BOOL)isReadable:(NSString *)path;
+(BOOL)isWritable:(NSString *)path;

#pragma mark - list

+(NSArray *)listDirInDir:(NSString *)path;
+(NSArray *)listDirInDir:(NSString *)path deep:(BOOL)deep;

+(NSArray *)listFilesInDir:(NSString *)path;
+(NSArray *)listFilesInDir:(NSString *)path deep:(BOOL)deep;

+(NSArray *)listFilesInDir:(NSString *)path withExtension:(NSString *)extension;
+(NSArray *)listFilesInDir:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep;

+(NSArray *)listFilesInDir:(NSString *)path withPrefix:(NSString *)prefix;
+(NSArray *)listFilesInDir:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep;

+(NSArray *)listFilesInDir:(NSString *)path withSuffix:(NSString *)suffix;
+(NSArray *)listFilesInDir:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep;

+(NSArray *)listItemsInDir:(NSString *)path deep:(BOOL)deep;

#pragma mark -
#pragma mark move
+(BOOL)move:(NSString *)path toPath:(NSString *)toPath;
+(BOOL)move:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+(BOOL)move:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;
+(BOOL)move:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark -
#pragma mark path

+(NSString *)pathForApplicationSupportDirectory;
+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path;

+(NSString *)pathForCachesDirectory;
+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path;

+(NSString *)pathForDocumentsDirectory;
+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path;

+(NSString *)pathForLibraryDirectory;
+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path;

+(NSString *)pathForMainBundleDirectory;
+(NSString *)pathForMainBundleDirectoryWithPath:(NSString *)path;

+(NSString *)pathForPlistNamed:(NSString *)name;

+(NSString *)pathForTemporaryDirectory;
+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path;

#pragma mark -
#pragma mark read
+(NSArray *)readFileAsArray:(NSString *)path;

+(NSObject *)readFileAsCustomModel:(NSString *)path;

+(NSData *)readFileAsData:(NSString *)path;
+(NSData *)readFileAsData:(NSString *)path error:(NSError **)error;

+(NSDictionary *)readFileAsDictionary:(NSString *)path;

+(UIImage *)readFileAtPathAsImage:(NSString *)path;
+(UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error;

+(UIImageView *)readFileAsImageView:(NSString *)path;
+(UIImageView *)readFileAsImageView:(NSString *)path error:(NSError **)error;

+(NSJSONSerialization *)readFileAsJSON:(NSString *)path;
+(NSJSONSerialization *)readFileAsJSON:(NSString *)path error:(NSError **)error;

+(NSMutableArray *)readFileAsMutableArray:(NSString *)path;

+(NSMutableData *)readFileAsMutableData:(NSString *)path;
+(NSMutableData *)readFileAsMutableData:(NSString *)path error:(NSError **)error;

+(NSMutableDictionary *)readFileAsMutableDictionary:(NSString *)path;

+(NSString *)readFileAsString:(NSString *)path;
+(NSString *)readFileAsString:(NSString *)path error:(NSError **)error;

#pragma mark - 
#pragma mark remove

+(BOOL)removeFilesInDir:(NSString *)path;
+(BOOL)removeFilesInDir:(NSString *)path error:(NSError **)error;

+(BOOL)removeFilesInDir:(NSString *)path withExtension:(NSString *)extension;
+(BOOL)removeFilesInDir:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error;

+(BOOL)removeFilesInDir:(NSString *)path withPrefix:(NSString *)prefix;
+(BOOL)removeFilesInDir:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error;

+(BOOL)removeFilesInDir:(NSString *)path withSuffix:(NSString *)suffix;
+(BOOL)removeFilesInDir:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error;

+(BOOL)removeItemsInDir:(NSString *)path;
+(BOOL)removeItemsInDir:(NSString *)path error:(NSError **)error;

+(BOOL)remove:(NSString *)path;
+(BOOL)remove:(NSString *)path error:(NSError **)error;

#pragma mark - rename

+(BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name;
+(BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name error:(NSError **)error;

+(NSString *)sizeFormatted:(NSNumber *)size;

+(NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path;
+(NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path;
+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error;

+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path;
+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error;

+(NSNumber *)sizeOfDirectoryAtPath:(NSString *)path;
+(NSNumber *)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

+(NSNumber *)sizeOfFileAtPath:(NSString *)path;
+(NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error;

+(NSNumber *)sizeOfItemAtPath:(NSString *)path;
+(NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error;

+(NSURL *)urlForItemAtPath:(NSString *)path;

+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content;
+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;

+(NSDictionary *)metadataOfImageAtPath:(NSString *)path;
+(NSDictionary *)exifDataOfImageAtPath:(NSString *)path;
+(NSDictionary *)tiffDataOfImageAtPath:(NSString *)path;

+(NSDictionary *)xattrOfItemAtPath:(NSString *)path;
+(NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key;
+(BOOL)xattrOfItemAtPath:(NSString *)path hasValueForKey:(NSString *)key;
+(BOOL)xattrOfItemAtPath:(NSString *)path removeValueForKey:(NSString *)key;
+(BOOL)xattrOfItemAtPath:(NSString *)path setValue:(NSString *)value forKey:(NSString *)key;

@end






