//
//  KCFileArchiver.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KCFileArchiver : NSObject {
	
	// buffer data after read file
	NSMutableData	* filedata;		
	
	// buffer data for write file
	NSData			* writedata;	
	
	///	write file using filestream
	NSOutputStream	* stream;
	///	stream datasize have been written since start
	long long		  streamDataSize;
}

@property (retain) NSMutableData * filedata;
@property (retain) NSData * writedata;
@property (retain) NSOutputStream * stream;
@property long long streamDataSize;


//
//	init function
//
-(id)init;

-(id)initWithDirPath:(NSString*)aDirPath;

//
//	read archive file in sandbox, with name
//	name cann't be nil
//	return nil if argument error or file not exist.
//	don't release return data
//
-(NSMutableData*) readPathFileWithName:(NSString *)filename;


//
//	write data to archive file in sandbox
//	name and data cann't be nil both
//	return NO if argument error or file I/O error
//
-(BOOL) writePathFileForName:(NSString*)filename
					withData:(NSData*)data;



//
//	write data to archive file using filestream
//	using this method can write file continuely by append
//	this method contain 3 step:
//
//		writePathFileUsingStreamStartWithName:append:
//
//		writePathFileUsingStreamWithData:
//
//		writePathFileUsingStreamClose
//
//	any step can't be obmitted!
//
-(BOOL) writePathFileUsingStreamStartWithName:(NSString *)filename 
									   append:(BOOL)writeAppend;
-(BOOL) writePathFileUsingStreamWithData:(NSData *)data;
-(void) writePathFileUsingStreamClose;


@end