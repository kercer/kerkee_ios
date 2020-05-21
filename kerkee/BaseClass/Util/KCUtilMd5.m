//
//  KCUtilMd5.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilMd5.h"
#import <CommonCrypto/CommonDigest.h>
#import "KCBaseDefine.h"

@implementation KCUtilMd5

+ (NSString*)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) {
        return nil;
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
}


+ (NSData *)MD5:(NSData*)data
{
	unsigned char md5Result[CC_MD5_DIGEST_LENGTH + 1];
	CC_MD5( [data bytes], (CC_LONG)[data length], md5Result );
    
	NSMutableData * retData = [[NSMutableData alloc] init];
    KCAutorelease(retData);
	if ( nil == retData )
		return nil;
    
	[retData appendBytes:md5Result length:CC_MD5_DIGEST_LENGTH];
	return retData;
}

+ (NSString *)MD5String:(NSData*)data
{
	NSData * value = [KCUtilMd5 MD5:data];
	if ( value )
	{
		char			tmp[16];
		unsigned char *	hex = (unsigned char *)malloc( 2048 + 1 );
		unsigned char *	bytes = (unsigned char *)[value bytes];
		unsigned long	length = [value length];
        
		hex[0] = '\0';
        
		for ( unsigned long i = 0; i < length; ++i )
		{
			sprintf( tmp, "%02X", bytes[i] );
			strcat( (char *)hex, tmp );
		}
        
		NSString * result = [NSString stringWithUTF8String:(const char *)hex];
		free( hex );
		return result;
	}
	else
	{
		return nil;
	}
}

@end
