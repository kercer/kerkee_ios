//
//  KCUtilDevice.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilDevice.h"
#include <sys/sysctl.h>
#include <spawn.h>


@implementation KCUtilDevice

static const char * __jb_app = NULL;
+ (BOOL)isJailbroken {
	static const char * __jb_apps[] =
	{
		"/Applications/Cydia.app",
		"/Applications/limera1n.app",
		"/Applications/greenpois0n.app",
		"/Applications/blackra1n.app",
		"/Applications/blacksn0w.app",
		"/Applications/redsn0w.app",
		NULL
	};
    
	__jb_app = NULL;
    
	// method 1
    for ( int i = 0; __jb_apps[i]; ++i )
    {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__jb_apps[i]]] )
        {
			__jb_app = __jb_apps[i];
			return YES;
        }
    }
    
    // method 2
	if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] )
	{
		return YES;
	}
    
//#pragma GCC diagnostic push
//#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//    // method 3
//    if ( 0 == system("ls") )
//    {
//        return YES;
//    }
//
//#pragma GCC diagnostic pop
    

    
    return NO;
}

+ (NSString *)jailBreaker
{
	if ( __jb_app )
	{
		return [NSString stringWithUTF8String:__jb_app];
	}
	else
	{
		return @"";
	}
}


+(NSString*)createUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}


@end
