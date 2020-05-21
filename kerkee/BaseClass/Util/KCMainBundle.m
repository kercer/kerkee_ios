//
//  UCMainBundle.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCMainBundle.h"
#import <SSKeychain/SSKeychain.h>
#import "KCUtilDevice.h"

#define FIRST_LAUNCH  @"firstLaunch"
#define FIRST_LAUNCH_AFTER_VERSION_CHANGED @"firstLaunchAfterInstall"
#define EVER_LAUNCHED @"everLaunched"
#define VersionFullName @"versionFullName"

#define GUUID_SELF @"GUUID_SELF"
#define UUID_SELF @"UUID_SELF"

@implementation KCMainBundle

__attribute__((constructor))
static void initializeSetting()
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:EVER_LAUNCHED])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:EVER_LAUNCHED];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_LAUNCH];
        
        [[NSUserDefaults standardUserDefaults] setValue:[KCUtilDevice createUUID] forKey:GUUID_SELF];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FIRST_LAUNCH];
    }
    
    NSString* strCurVersion = [KCMainBundle getVersionFullName];
    NSString* strVersion = [[NSUserDefaults standardUserDefaults] stringForKey:VersionFullName];
    if (![strCurVersion isEqualToString:strVersion])//version changed
    {
        [[NSUserDefaults standardUserDefaults] setValue:strCurVersion forKey:VersionFullName];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_LAUNCH_AFTER_VERSION_CHANGED];
        
        [[NSUserDefaults standardUserDefaults] setValue:[KCUtilDevice createUUID] forKey:UUID_SELF];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FIRST_LAUNCH_AFTER_VERSION_CHANGED];
    }
    
}



+ (BOOL)isFirstLaunch
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_LAUNCH];
}

+ (BOOL)isFirstLaunchAfterVersionChanged
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_LAUNCH_AFTER_VERSION_CHANGED];
}


+ (NSString*)getIdentifier
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (BOOL)isSelfApp:(NSString*)identifier
{
    return [[KCMainBundle getIdentifier] isEqualToString:identifier] ? YES : NO;
}
+ (NSString*)getVersionName
{
    return [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString*)getBuildCode
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString*)getVersionFullName
{
    NSBundle *bundle = [NSBundle mainBundle]; //[NSBundle bundleForClass:[self class]];
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    return appVersion;
}

+ (NSString*)getDisplayName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (CGSize)getScreenSize
{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    return size_screen;
}
+ (CGFloat)getStateBarHeight
{
    return 20;
}

static NSString* sKeychainServiceGUID = nil;
static NSString* sKeychainAccount = nil;
+ (NSString*)getKeychainAccount
{
    if (!sKeychainAccount)
        sKeychainAccount = [NSString stringWithFormat:@"Keychain_Account_%@", [self getIdentifier]];
    return sKeychainAccount;
}
+ (NSString*)getKeychainServiceForGUID
{
    if (!sKeychainServiceGUID)
        sKeychainServiceGUID = [NSString stringWithFormat:@"Keychain_Service_GUID_%@", [self getIdentifier]];
    return sKeychainServiceGUID;
}

+ (NSString*)getGUDID
{
    NSString* uuid = Nil;
    uuid = [SSKeychain passwordForService:[self getKeychainServiceForGUID] account:[self getKeychainAccount]];
    if ( !uuid )
    {
        uuid = [KCUtilDevice createUUID];
        [SSKeychain setPassword:uuid forService:[self getKeychainServiceForGUID] account:[self getKeychainAccount]];
    }
    
    return uuid;
}

+ (NSString*)getUUIDWithKey:(NSString*)aKey
{
    NSString* uuid = [[NSUserDefaults standardUserDefaults] stringForKey:aKey];
    if(uuid && uuid.length>0) return uuid;
    
    NSString* uuidCreate = [KCUtilDevice createUUID];
    [[NSUserDefaults standardUserDefaults] setValue:uuidCreate forKey:aKey];
    return uuidCreate;
}

+ (NSString*)getGUUID
{
    return [self getUUIDWithKey:GUUID_SELF];
}


+ (NSString*)getUUID
{
    return [self getUUIDWithKey:UUID_SELF];
}

@end
