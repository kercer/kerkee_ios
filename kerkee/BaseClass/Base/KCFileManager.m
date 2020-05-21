
#import "KCFileManager.h"
#import <sys/xattr.h>
#include "sys/stat.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <objc/runtime.h>

#import "KCTaskQueue.h"

@implementation KCFileManager


+(NSMutableArray *)allAbsoluteDirectories
{
    static NSMutableArray *directories = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        directories = [NSMutableArray arrayWithObjects:
                                [self pathForApplicationSupportDirectory],
                                [self pathForCachesDirectory],
                                [self pathForDocumentsDirectory],
                                [self pathForLibraryDirectory],
                                [self pathForMainBundleDirectory],
                                [self pathForTemporaryDirectory],
                                nil];
        
        [directories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return (((NSString *)obj1).length > ((NSString *)obj2).length) ? 0 : 1;
            
        }];
    });
    
    return directories;
}


+(NSString *)matchingAbsoluteDirectoryForPath:(NSString *)aPath
{
    if (aPath == nil)
    {
        return nil;
    }
    [self assertPath:aPath];
    
    if([aPath isEqualToString:@"/"])
    {
        return nil;
    }
    
    NSMutableArray *directories = [self allAbsoluteDirectories];
    
    for(NSString *directory in directories)
    {
        NSRange indexOfDirectoryInPath = [aPath rangeOfString:directory];
        
        if(indexOfDirectoryInPath.location == 0)
        {
            return directory;
        }
    }
    
    return nil;
}


+ (BOOL)isAbsolute:(NSString *)aPath
{
    if (!aPath) return false;
    return aPath.length > 0 && [aPath characterAtIndex:0] == '/';
}


+(NSString *)absolutePath:(NSString *)aPath
{
    [self assertPath:aPath];
    
    if ([self isAbsolute:aPath])
    {
        return aPath;
    }
    else
    {
        return [self pathForDocumentsDirectoryWithPath:aPath];
    }
}


+(void)assertPath:(NSString *)path
{
    if (path == nil)
    {
        return;
    }
    NSAssert(path != nil, @"Invalid path. Path cannot be nil.");
    NSAssert(![path isEqualToString:@""], @"Invalid path. Path cannot be empty string.");
}


+(id)attribute:(NSString *)aPath forKey:(NSString *)aKey
{
    return [[self attributes:aPath] objectForKey:aKey];
}


+(id)attribute:(NSString *)aPath forKey:(NSString *)aKey error:(NSError **)aError
{
    return [[self attributes:aPath error:aError] objectForKey:aKey];
}


+(NSDictionary *)attributes:(NSString *)path
{
    return [self attributes:path error:nil];
}


+(NSDictionary *)attributes:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath:path] error:error];
}


+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath
{
    return [self copy:path toPath:toPath overwrite:NO error:nil];
}


+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error
{
    return [self copy:path toPath:toPath overwrite:NO error:error];
}


+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite
{
    return [self copy:path toPath:toPath overwrite:overwrite error:nil];
}


+(BOOL)copy:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error
{
    if(![self exists:toPath] || (overwrite && [self remove:toPath error:error] && [self isNotError:error]))
    {
        if([self createDirForFilePath:toPath error:error])
        {
            BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error];
            
            return (copied && [self isNotError:error]);
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

+(void)copyAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    BOOL isSucceed = [self copy:fromPath toPath:toPath];
    FOREGROUND_BEGIN
    if (aBlock)
        aBlock(isSucceed);
    FOREGROUND_COMMIT
    
    BACKGROUND_GLOBAL_COMMIT
    
}

+(BOOL)move:(NSString *)path toPath:(NSString *)toPath
{
    return [self move:path toPath:toPath overwrite:NO error:nil];
}


+(BOOL)move:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error
{
    return [self move:path toPath:toPath overwrite:NO error:error];
}


+(BOOL)move:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite
{
    return [self move:path toPath:toPath overwrite:overwrite error:nil];
}


+(BOOL)move:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error
{
    if(![self exists:toPath] || (overwrite && [self remove:toPath error:error] && [self isNotError:error]))
    {
        return ([self createDirForFilePath:toPath error:error] && [[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error]);
    }
    else {
        return NO;
    }
}


+(void)moveAsyn:(NSString*)fromPath toPath:(NSString*)toPath block:(void(^)(BOOL aIsSucceed))aBlock
{
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    BOOL isSucceed = [self move:fromPath toPath:toPath];
    FOREGROUND_BEGIN
    if (aBlock)
        aBlock(isSucceed);
    FOREGROUND_COMMIT
    
    BACKGROUND_GLOBAL_COMMIT
}




+(BOOL)createDirForFilePath:(NSString *)path
{
    return [self createDirForFilePath:path error:nil];
}


+(BOOL)createDirForFilePath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if([pathLastChar isEqualToString:@"/"])
    {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];
        
        return NO;
    }
    
    return [self createDirForPath:[[self absolutePath:path] stringByDeletingLastPathComponent] error:error];
}


+(BOOL)createDirForPath:(NSString *)path
{
    return [self createDirForPath:path error:nil];
}


+(BOOL)createDirForPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:YES attributes:nil error:error];
}


+(BOOL)createFile:(NSString *)path
{
    return [self createFile:path withContent:nil overwrite:NO error:nil];
}


+(BOOL)createFile:(NSString *)path error:(NSError **)error
{
    return [self createFile:path withContent:nil overwrite:NO error:error];
}


+(BOOL)createFile:(NSString *)path overwrite:(BOOL)overwrite
{
    return [self createFile:path withContent:nil overwrite:overwrite error:nil];
}


+(BOOL)createFile:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error
{
    return [self createFile:path withContent:nil overwrite:overwrite error:error];
}


+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content
{
    return [self createFile:path withContent:content overwrite:NO error:nil];
}


+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content error:(NSError **)error
{
    return [self createFile:path withContent:content overwrite:NO error:error];
}


+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite
{
    return [self createFile:path withContent:content overwrite:overwrite error:nil];
}


+(BOOL)createFile:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error
{
    if(![self exists:path] || (overwrite && [self remove:path error:error] && [self isNotError:error]))
    {
        if([self createDirForFilePath:path error:error])
        {
            BOOL created = [[NSFileManager defaultManager] createFileAtPath:[self absolutePath:path] contents:nil attributes:nil];
            
            if(content != nil)
            {
                [self writeFileAtPath:path content:content error:error];
            }
            
            return (created && [self isNotError:error]);
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}


+(NSDate *)creationDate:(NSString *)path
{
    return [self creationDate:path error:nil];
}


+(NSDate *)creationDate:(NSString *)path error:(NSError **)error
{
    return (NSDate *)[self attribute:path forKey:NSFileCreationDate error:error];
}


+(BOOL)emptyCachesDir
{
    return [self removeFilesInDir:[self pathForCachesDirectory]];
}


+(BOOL)emptyTemporaryDir
{
    return [self removeFilesInDir:[self pathForTemporaryDirectory]];
}


+(BOOL)exists:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path]];
}

+(BOOL)existsFast:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+(BOOL)isDir:(NSString *)path
{
    return [self isDir:path error:nil];
}


+(BOOL)isDir:(NSString *)path error:(NSError **)error
{
    return ([self attribute:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}


+(BOOL)isEmpty:(NSString *)path
{
    return [self isEmpty:path error:nil];
}


+(BOOL)isEmpty:(NSString *)path error:(NSError **)error
{
    return ([self isFile:path error:error] && ([[self sizeOfItemAtPath:path error:error] intValue] == 0)) || ([self isDir:path error:error] && ([[self listItemsInDir:path deep:NO] count] == 0));
}


+(BOOL)isFile:(NSString *)path
{
    return [self isFile:path error:nil];
}


+(BOOL)isFile:(NSString *)path error:(NSError **)error
{
    return ([self attribute:path forKey:NSFileType error:error] == NSFileTypeRegular);
}


+(BOOL)isExecutable:(NSString *)path
{
    return [[NSFileManager defaultManager] isExecutableFileAtPath:[self absolutePath:path]];
}


+(BOOL)isNotError:(NSError **)error
{
    //the first check prevents EXC_BAD_ACCESS error in case methods are called passing nil to error argument
    //the second check prevents that the methods returns always NO just because the error pointer exists (so the first condition returns YES)
    return ((error == nil) || ((*error) == nil));
}


+(BOOL)isReadable:(NSString *)path
{
    return [[NSFileManager defaultManager] isReadableFileAtPath:[self absolutePath:path]];
}


+(BOOL)isWritable:(NSString *)path
{
    return [[NSFileManager defaultManager] isWritableFileAtPath:[self absolutePath:path]];
}


+(NSArray *)listDirInDir:(NSString *)path
{
    return [self listDirInDir:path deep:NO];
}


+(NSArray *)listDirInDir:(NSString *)path deep:(BOOL)deep
{
    NSArray *subpaths = [self listItemsInDir:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        
        return [self isDir:subpath];
    }]];
}


+(NSArray *)listFilesInDir:(NSString *)path
{
    return [self listFilesInDir:path deep:NO];
}


+(NSArray *)listFilesInDir:(NSString *)path deep:(BOOL)deep
{
    NSArray *subpaths = [self listItemsInDir:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        
        return [self isFile:subpath];
    }]];
}


+(NSArray *)listFilesInDir:(NSString *)path withExtension:(NSString *)extension
{
    return [self listFilesInDir:path withExtension:extension deep:NO];
}


+(NSArray *)listFilesInDir:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDir:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *subpathExtension = [[subpath pathExtension] lowercaseString];
        NSString *filterExtension = [[extension lowercaseString] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        return [subpathExtension isEqualToString:filterExtension];
    }]];
}


+(NSArray *)listFilesInDir:(NSString *)path withPrefix:(NSString *)prefix
{
    return [self listFilesInDir:path withPrefix:prefix deep:NO];
}


+(NSArray *)listFilesInDir:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDir:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        
        return ([subpath hasPrefix:prefix] || [subpath isEqualToString:prefix]);
    }]];
}


+(NSArray *)listFilesInDir:(NSString *)path withSuffix:(NSString *)suffix
{
    return [self listFilesInDir:path withSuffix:suffix deep:NO];
}


+(NSArray *)listFilesInDir:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDir:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *subpathName = [subpath stringByDeletingPathExtension];
        
        return ([subpath hasSuffix:suffix] || [subpath isEqualToString:suffix] || [subpathName hasSuffix:suffix] || [subpathName isEqualToString:suffix]);
    }]];
}


+(NSArray *)listItemsInDir:(NSString *)path deep:(BOOL)deep
{
    NSString *absolutePath = [self absolutePath:path];
    NSArray *relativeSubpaths = (deep ? [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:absolutePath error:nil] : [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil]);
    
    NSMutableArray *absoluteSubpaths = [[NSMutableArray alloc] init];
    
    for(NSString *relativeSubpath in relativeSubpaths)
    {
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }
    
    return [NSArray arrayWithArray:absoluteSubpaths];
}



+(NSString *)pathForApplicationSupportDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}


+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForApplicationSupportDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForCachesDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}


+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForCachesDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForDocumentsDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}


+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForDocumentsDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForLibraryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}


+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForLibraryDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForMainBundleDirectory
{
    return [NSBundle mainBundle].resourcePath;
}


+(NSString *)pathForMainBundleDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForMainBundleDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if([nameExtension isEqualToString:@""])
    {
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    
    return [self pathForMainBundleDirectoryWithPath:name];
}


+(NSString *)pathForTemporaryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        path = NSTemporaryDirectory();
    });
    
    return path;
}


+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path
{
    return [[KCFileManager pathForTemporaryDirectory] stringByAppendingPathComponent:path];
}




+(NSArray *)readFileAsArray:(NSString *)path
{
    return [NSArray arrayWithContentsOfFile:[self absolutePath:path]];
}


+(NSObject *)readFileAsCustomModel:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self absolutePath:path]];
}


+(NSData *)readFileAsData:(NSString *)path
{
    return [self readFileAsData:path error:nil];
}


+(NSData *)readFileAsData:(NSString *)path error:(NSError **)error
{
    return [NSData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMapped error:error];
}


+(NSDictionary *)readFileAsDictionary:(NSString *)path
{
    return [NSDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}


+(UIImage *)readFileAtPathAsImage:(NSString *)path
{
    return [self readFileAtPathAsImage:path error:nil];
}


+(UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAsData:path error:error];
    
    if([self isNotError:error])
    {
        return [UIImage imageWithData:data];
    }
    
    return nil;
}


+(UIImageView *)readFileAsImageView:(NSString *)path
{
    return [self readFileAsImageView:path error:nil];
}


+(UIImageView *)readFileAsImageView:(NSString *)path error:(NSError **)error
{
    UIImage *image = [self readFileAtPathAsImage:path error:error];
    
    if([self isNotError:error])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView sizeToFit];
        return imageView;
    }
    
    return nil;
}


+(NSJSONSerialization *)readFileAsJSON:(NSString *)path
{
    return [self readFileAsJSON:path error:nil];
}


+(NSJSONSerialization *)readFileAsJSON:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAsData:path error:error];
    
    if([self isNotError:error])
    {
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        
        if([NSJSONSerialization isValidJSONObject:json])
        {
            return json;
        }
    }
    
    return nil;
}


+(NSMutableArray *)readFileAsMutableArray:(NSString *)path
{
    return [NSMutableArray arrayWithContentsOfFile:[self absolutePath:path]];
}


+(NSMutableData *)readFileAsMutableData:(NSString *)path
{
    return [self readFileAsMutableData:path error:nil];
}


+(NSMutableData *)readFileAsMutableData:(NSString *)path error:(NSError **)error
{
    return [NSMutableData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMapped error:error];
}


+(NSMutableDictionary *)readFileAsMutableDictionary:(NSString *)path
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}


+(NSString *)readFileAsString:(NSString *)path
{
    return [self readFileAsString:path error:nil];
}


+(NSString *)readFileAsString:(NSString *)path error:(NSError **)error
{
    return [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:error];
}


+(BOOL)removeFilesInDir:(NSString *)path
{
    return [self removeItemsAtPaths:[self listFilesInDir:path] error:nil];
}


+(BOOL)removeFilesInDir:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDir:path] error:error];
}


+(BOOL)removeFilesInDir:(NSString *)path withExtension:(NSString *)extension
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withExtension:extension] error:nil];
}


+(BOOL)removeFilesInDir:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withExtension:extension] error:error];
}


+(BOOL)removeFilesInDir:(NSString *)path withPrefix:(NSString *)prefix
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withPrefix:prefix] error:nil];
}


+(BOOL)removeFilesInDir:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withPrefix:prefix] error:error];
}


+(BOOL)removeFilesInDir:(NSString *)path withSuffix:(NSString *)suffix
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withSuffix:suffix] error:nil];
}


+(BOOL)removeFilesInDir:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDir:path withSuffix:suffix] error:error];
}


+(BOOL)removeItemsInDir:(NSString *)path
{
    return [self removeItemsInDir:path error:nil];
}


+(BOOL)removeItemsInDir:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listItemsInDir:path deep:NO] error:error];
}


+(BOOL)remove:(NSString *)path
{
    return [self remove:path error:nil];
}


+(BOOL)remove:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self absolutePath:path] error:error];
}


+(BOOL)removeItemsAtPaths:(NSArray *)paths
{
    return [self removeItemsAtPaths:paths error:nil];
}


+(BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;
    
    for(NSString *path in paths)
    {
        success &= [self remove:[self absolutePath:path] error:error];
    }
    
    return success;
}

+(BOOL)renameItemAtPath:(NSString*)aPath toPath:(NSString*)aToPath
{
    return [self renameItemAtPath:aPath toPath:aToPath error:nil];
}
+(BOOL)renameItemAtPath:(NSString*)aPath toPath:(NSString*)aToPath error:(NSError **)aError
{
    return [self move:aPath toPath:aToPath error:aError];
}

+(BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name
{
    return [self renameItemAtPath:path withName:name error:nil];
}


+(BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name error:(NSError **)error
{
    NSRange indexOfSlash = [name rangeOfString:@"/"];
    
    if(indexOfSlash.location < name.length)
    {
        [NSException raise:@"Invalid name" format:@"file name can't contain a '/'."];
        
        return NO;
    }
    
    return [self move:path toPath:[[[self absolutePath:path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:name] error:error];
}


+(NSString *)sizeFormatted:(NSNumber *)size
{
    //TODO if OS X 10.8 or iOS 6
    //return [NSByteCountFormatter stringFromByteCount:[size intValue] countStyle:NSByteCountFormatterCountStyleFile];
    
    double convertedValue = [size doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];
    
    while(convertedValue > 1024){
        convertedValue /= 1024;
        
        multiplyFactor++;
    }
    
    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");
    
    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}


+(NSString *)sizeFormattedOfDirAtPath:(NSString *)path
{
    return [self sizeFormattedOfDirAtPath:path error:nil];
}


+(NSString *)sizeFormattedOfDirAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfDirAtPath:path error:error];
    
    if(size != nil && [self isNotError:error])
    {
        return [self sizeFormatted:size];
    }
    
    return nil;
}


+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path
{
    return [self sizeFormattedOfFileAtPath:path error:nil];
}


+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfFileAtPath:path error:error];
    
    if(size != nil && [self isNotError:error])
    {
        return [self sizeFormatted:size];
    }
    
    return nil;
}


+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path
{
    return [self sizeFormattedOfItemAtPath:path error:nil];
}


+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    
    if(size != nil && [self isNotError:error])
    {
        return [self sizeFormatted:size];
    }
    
    return nil;
}


+(NSNumber *)sizeOfDirAtPath:(NSString *)path
{
    return [self sizeOfDirAtPath:path error:nil];
}


+(NSNumber *)sizeOfDirAtPath:(NSString *)path error:(NSError **)error
{
    if([self isDir:path error:error])
    {
        if([self isNotError:error])
        {
            NSNumber *size = [self sizeOfItemAtPath:path error:error];
            double sizeValue = [size doubleValue];
            
            if([self isNotError:error])
            {
                NSArray *subpaths = [self listItemsInDir:path deep:YES];
                NSUInteger subpathsCount = [subpaths count];
                
                for(NSUInteger i = 0; i < subpathsCount; i++)
                {
                    NSString *subpath = [subpaths objectAtIndex:i];
                    NSNumber *subpathSize = [self sizeOfItemAtPath:subpath error:error];
                    
                    if([self isNotError:error])
                    {
                        sizeValue += [subpathSize doubleValue];
                    }
                    else {
                        return nil;
                    }
                }
                
                return [NSNumber numberWithDouble:sizeValue];
            }
        }
    }
    
    return nil;
}


+(NSNumber *)sizeOfFileAtPath:(NSString *)path
{
    return [self sizeOfFileAtPath:path error:nil];
}


+(NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error
{
    if([self isFile:path error:error])
    {
        if([self isNotError:error])
        {
            return [self sizeOfItemAtPath:path error:error];
        }
    }
    
    return nil;
}


+(NSNumber *)sizeOfItemAtPath:(NSString *)path
{
    return [self sizeOfItemAtPath:path error:nil];
}


+(NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSNumber *)[self attribute:path forKey:NSFileSize error:error];
}

+ (unsigned long long) sizeOfFileFromStatAtPath:(NSString*) filePath
{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
    {
        return st.st_size;
    }
    return 0;
}


+ (unsigned long long) sizeOfDirFromStatAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self sizeOfFileFromStatAtPath:fileAbsolutePath];
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


+(NSURL *)urlForItemAtPath:(NSString *)path
{
    return [NSURL fileURLWithPath:[self absolutePath:path]];
}


+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content
{
    return [self writeFileAtPath:path content:content error:nil];
}


+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error
{
    if(content == nil)
    {
        [NSException raise:@"Invalid content" format:@"content can't be nil."];
    }
    
    [self createFile:path withContent:nil overwrite:YES error:error];
    
    NSString *absolutePath = [self absolutePath:path];
    
    if([content isKindOfClass:[NSMutableArray class]])
    {
        [((NSMutableArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSArray class]])
    {
        [((NSArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableData class]])
    {
        [((NSMutableData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSData class]])
    {
        [((NSData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSDictionary class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSJSONSerialization class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImage class]])
    {
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImageView class]])
    {
        return [self writeFileAtPath:absolutePath content:((UIImageView *)content).image error:error];
    }
    else if([content conformsToProtocol:@protocol(NSCoding)])
    {
        [NSKeyedArchiver archiveRootObject:content toFile:absolutePath];
    }
    else {
        [NSException raise:@"Invalid content type" format:@"content of type %@ is not handled.", NSStringFromClass([content class])];
        
        return NO;
    }

    return YES;
}


+(NSDictionary *)metadataOfImageAtPath:(NSString *)path
{
    if([self isFile:path])
    {
        //http://blog.depicus.com/getting-exif-data-from-images-on-ios/
        
        NSURL *url = [self urlForItemAtPath:path];
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL));
        
        CFRelease(sourceRef);
        return metadata;
    }
    
    return nil;
}


+(NSDictionary *)exifDataOfImageAtPath:(NSString *)path
{
    NSDictionary *metadata = [self metadataOfImageAtPath:path];
    
    if(metadata)
    {
        return [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    }
    
    return nil;
}


+(NSDictionary *)tiffDataOfImageAtPath:(NSString *)path
{
    NSDictionary *metadata = [self metadataOfImageAtPath:path];
    
    if(metadata)
    {
        return [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    
    return nil;
}


+(NSDictionary *)xattrOfItemAtPath:(NSString *)path
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    const char *upath = [path UTF8String];
    
    ssize_t ukeysSize = listxattr(upath, NULL, 0, 0);
    
    if( ukeysSize > 0 )
    {
        char *ukeys = malloc(ukeysSize);
        
        ukeysSize = listxattr(upath, ukeys, ukeysSize, 0);
        
        NSUInteger keyOffset = 0;
        NSString *key;
        NSString *value;
        
        while(keyOffset < ukeysSize)
        {
            key = [NSString stringWithUTF8String:(keyOffset + ukeys)];
            keyOffset += ([key length] + 1);
            
            value = [self xattrOfItemAtPath:path getValueForKey:key];
            [values setObject:value forKey:key];
        }
        
        free(ukeys);
    }
    
    return [NSDictionary dictionaryWithObjects:[values allKeys] forKeys:[values allValues]];
}


+(NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key
{
    NSString *value = nil;
    
    const char *ukey = [key UTF8String];
    const char *upath = [path UTF8String];
    
    ssize_t uvalueSize = getxattr(upath, ukey, NULL, 0, 0, 0);
    
    if( uvalueSize > -1 )
    {
        if( uvalueSize == 0 )
        {
            value = @"";
        }
        else {
            
            char *uvalue = malloc(uvalueSize);
            
            if( uvalue )
            {
                getxattr(upath, ukey, uvalue, uvalueSize, 0, 0);
                uvalue[uvalueSize] = '\0';
                value = [NSString stringWithUTF8String:uvalue];
                free(uvalue);
            }
        }
    }
    
    return value;
}


+(BOOL)xattrOfItemAtPath:(NSString *)path hasValueForKey:(NSString *)key
{
    return ([self xattrOfItemAtPath:path getValueForKey:key] != nil);
}


+(BOOL)xattrOfItemAtPath:(NSString *)path removeValueForKey:(NSString *)key
{
    int result = removexattr([path UTF8String], [key UTF8String], 0);
    
    return (result == 0);
}


+(BOOL)xattrOfItemAtPath:(NSString *)path setValue:(NSString *)value forKey:(NSString *)key
{
    if(value == nil)
    {
        return NO;
    }
    
    int result = setxattr([path UTF8String], [key UTF8String], [value UTF8String], [value length], 0, 0);
    
    return (result == 0);
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



