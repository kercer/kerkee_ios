//
//  KCAssistant.m
//  kerkee
//
//  Created by zihong on 15/9/23.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCHelper.h"
#import "KCWebPathDefine.h"
#import "ZipArchive.h"
#import "KCBaseDefine.h"
#import "KCFileManager.h"

@interface KCHelper()
{
}

@end

@implementation KCHelper

- (id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}

- (void)dealloc
{
    KCDealloc(super);
}

- (void)unzipHtml
{
    [self createRootPath];
    [self updateTemplateFile];
}

- (void)createRootPath
{
    [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath error:nil];
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:KCWebPath_HtmlRootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KCWebPath_HtmlRootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


- (void)updateTemplateFile
{
    NSString *zipBundlePath = [self getTemplateZipBundlePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipBundlePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:KCWebPath_HtmlRootPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:zipBundlePath toPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        
        [self unzipUpdateTemplateFile];
    }
}

- (NSString *)getTemplateZipBundlePath
{
    return [[NSBundle mainBundle] pathForResource:@"html" ofType:@"zip"];;
}


- (void)unzipUpdateTemplateFile
{
    NSString* zipPath = nil;
    BOOL isDirectory = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:KCWebPath_HtmlRootPath_ZipFile isDirectory:&isDirectory]) {
        zipPath = KCWebPath_HtmlRootPath_ZipFile;
    } else {
        return;
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    zipArchive.delegate = (id)self;
    
    if ([zipArchive UnzipOpenFile:zipPath]) {
        if([zipArchive UnzipFileTo:KCWebPath_HtmlLocalPath overWrite:YES]){
            [zipArchive UnzipCloseFile];
            [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        }
    }
    
    KCRelease(zipArchive);
    
    [KCFileManager addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:KCWebPath_HtmlRootPath]];
}


@end
