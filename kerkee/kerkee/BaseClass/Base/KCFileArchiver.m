//
//  KCFileArchiver.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCFileArchiver.h"
#import "KCBaseDefine.h"
#import "KCUtilFile.h"

@interface KCFileArchiver ()
{
    NSString* m_DirPath;
}

@end

@implementation KCFileArchiver
@synthesize filedata;
@synthesize writedata;	// add this for future arangement
@synthesize stream;
@synthesize streamDataSize;

-(NSString *) getPathFilePathWithName:(NSString *)filename
{
    NSString * filepath;
    
    if (m_DirPath)
    {
        filepath = [KCUtilFile appendToPath:m_DirPath FileName:filename];
    }
    else
    {
        NSArray * pathAry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        filepath = [pathAry objectAtIndex:0];
        filepath = [filepath stringByAppendingPathComponent:filename];
    }
	
	return filepath;
}

-(id)init
{
	if(self = [super init])
	{
		self.filedata = nil;
		self.writedata = nil;
	}
	
	return self;
}

-(id)initWithDirPath:(NSString*)aDirPath
{
    if (self = [super init])
    {
        self.filedata = nil;
        self.writedata = nil;
        m_DirPath = [aDirPath copy];
    }
    return self;
}


-(NSMutableData*) readPathFileWithName:(NSString *)filename
{
	if(nil != filedata)
	{
        KCRelease(filedata);
		filedata = nil;
	}
	
	if(nil == filename)
		return filedata;
	
	//	NSArray * pathAry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString * filepath = [pathAry objectAtIndex:0];
	//	filepath = [filepath stringByAppendingPathComponent:filename];
	NSString * filepath = [self getPathFilePathWithName:filename];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filepath])
	{	
		NSMutableData * data = [[NSMutableData alloc] initWithContentsOfFile:filepath];
		
		self.filedata = data;
        KCRelease(data);
	}
	
	return filedata;
}


-(BOOL) writePathFileForName:(NSString*)filename
					withData:(NSData*)data
{
	BOOL bRes = NO;
	
	if(nil == filename || nil == data)
		return bRes;
	
	//	NSArray * pathAry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString * filepath = [pathAry objectAtIndex:0];
	//	filepath = [filepath stringByAppendingPathComponent:filename];
	NSString * filepath = [self getPathFilePathWithName:filename];
	
	bRes = [data writeToFile:filepath atomically:YES];
	
	return bRes;
}


-(BOOL) writePathFileUsingStreamStartWithName:(NSString *)filename 
									   append:(BOOL)writeAppend
{
	if(nil == filename)
		return NO;
	
	if(nil != stream)
		[self writePathFileUsingStreamClose];
	
	self.stream = [NSOutputStream outputStreamToFileAtPath:[self getPathFilePathWithName:filename] 
													append:YES];
	[self.stream open];
	
	return YES;
}

-(BOOL) writePathFileUsingStreamWithData:(NSData *)data
{
	if(nil == data || 0 == [data length] || nil == stream)
		return NO;
	
	NSInteger dataLength = [data length];
	const uint8_t * dataBytes = [data bytes];
	
	NSInteger dataLenWrittenInThisSection = 0;
	while (dataLenWrittenInThisSection != dataLength) 
	{
		NSInteger bytesWritten = [stream write:dataBytes maxLength:(dataLength - dataLenWrittenInThisSection)];
		
		if(-1 == bytesWritten)
		{
			NSError * err = [stream streamError];
			NSLog(@"stream err:%@",[err localizedDescription]);

			[self writePathFileUsingStreamClose];
			return NO;
		}
		
		dataBytes += bytesWritten;
		streamDataSize += bytesWritten;
		dataLenWrittenInThisSection += bytesWritten;
	}
	
	return YES;
}

-(void) writePathFileUsingStreamClose
{
	if(nil != stream)
	{
		[stream close];
        KCRelease(stream);
		stream = nil;
	}
	streamDataSize = 0;
}



-(void)dealloc
{
	if(nil != filedata)
	{
        KCRelease(filedata);
		filedata = nil;
	}
	
	if(nil != writedata)
	{
        KCRelease(writedata);
		writedata = nil;
	}
    
    if (nil != m_DirPath)
    {
        KCRelease(m_DirPath);
        m_DirPath = nil;
    }
	
	if(nil != stream)
		[self writePathFileUsingStreamClose];
	
    KCDealloc(super);
}

@end
