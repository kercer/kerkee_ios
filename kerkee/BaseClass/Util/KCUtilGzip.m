//
//  KCUtilGzip.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilGzip.h"

#import <zlib.h>
#import <dlfcn.h>

@implementation KCUtilGzip

+ (NSData *)gzipData:(NSData *)pUncompressedData
{
	if (!pUncompressedData || [pUncompressedData length] == 0) {
		NSLog(@"%s: Error: Can't compress an empty or nil NSData object",__func__);
		return nil;
	}
	
	z_stream zlibStreamStruct;
	zlibStreamStruct.zalloc = Z_NULL;
	zlibStreamStruct.zfree = Z_NULL;
	zlibStreamStruct.opaque = Z_NULL;
	zlibStreamStruct.total_out = 0;
	zlibStreamStruct.next_in = (Bytef *)[pUncompressedData bytes];
	zlibStreamStruct.avail_in = (uInt)[pUncompressedData length];
	
	int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
	if (initError != Z_OK) {
		NSString *errorMsg = nil;
		switch (initError) {
			case Z_STREAM_ERROR:
				errorMsg = @"Invalid parameter passed in to function.";
				break;
			case Z_MEM_ERROR:
				errorMsg = @"Insufficient memory.";
				break;
			case Z_VERSION_ERROR:
				errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
				break;
			default:
				errorMsg = @"Unknown error code.";
				break;
		}
		NSLog(@"%s:deflateInit2() Error: \"%@\" Message: \"%s\"",__func__,errorMsg,zlibStreamStruct.msg);
		return nil;
	}
	
	NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 21];
	
	int deflateStatus;
	do {
		zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
		zlibStreamStruct.avail_out =(uInt)( [compressedData length] - zlibStreamStruct.total_out);
		deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
				
	} while (deflateStatus == Z_OK);
	
	if (deflateStatus != Z_STREAM_END) 
	{
	  NSString *errorMsg = nil;
	  switch (deflateStatus) {
		  case Z_ERRNO:
			  errorMsg = @"Error occured while reading file.";
			  break;
		  case Z_STREAM_ERROR:
			  errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
		  	  break;
		  case Z_DATA_ERROR:
			  errorMsg = @"The deflate data was invalid or incomplete.";
			  break;
		  case Z_MEM_ERROR:
			  errorMsg = @"Memory could not be allocated for processing.";
			  break;
		  case Z_BUF_ERROR:
			  errorMsg = @"Ran out of output buffer for writing compressed bytes.";
			  break;
		  case Z_VERSION_ERROR:
			  errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
			  break;			  	
		  default:
			  errorMsg = @"Unknown error code.";
			  break;
	  }
	  NSLog(@"%s:zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
	  deflateEnd(&zlibStreamStruct);
	  return nil;
	}
	
	deflateEnd(&zlibStreamStruct);
	[compressedData setLength:zlibStreamStruct.total_out];
	NSLog(@"%s: Compressed file from %d B to %d B", __func__, [pUncompressedData length], [compressedData length]);
	return compressedData;
}


+(NSData *)uncompressZippedData:(NSData *)compressedData  {  
	
	if ([compressedData length] == 0) return compressedData;  
	
    NSUInteger full_length = [compressedData length];
	
    NSUInteger half_length = [compressedData length] / 2;
	
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];  
	
    BOOL done = NO;  
	
    int status;  
	
    z_stream strm;  
	
    strm.next_in = (Bytef *)[compressedData bytes];  
	
    strm.avail_in =(uInt) [compressedData length];
	
    strm.total_out = 0;  
	
    strm.zalloc = Z_NULL;  
	
    strm.zfree = Z_NULL;  
	
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;  
	
    while (!done) {  
        // Make sure we have enough room and reset the lengths.  
        if (strm.total_out >= [decompressed length]) {  
            [decompressed increaseLengthBy: half_length];  
        }  
        strm.next_out = [decompressed mutableBytes] + strm.total_out;  
        strm.avail_out = (uInt) ([decompressed length] - strm.total_out);
        // Inflate another chunk.  
        status = inflate (&strm, Z_SYNC_FLUSH);  
        if (status == Z_STREAM_END) {  
            done = YES;  
        } else if (status != Z_OK) {  
            break;  
        }  
    }  
    if (inflateEnd (&strm) != Z_OK) return nil;  
    // Set real length.  
    if (done) {  
        [decompressed setLength: strm.total_out];  
        return [NSData dataWithData: decompressed];  
    } else {  
        return nil;  
    }  
}


BOOL kc_isGzippedData(NSData *data)
{
    UInt8 *bytes = (UInt8 *)data.bytes;
    return (data.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

NSData *kc_gzipData(NSData *input, float level)
{
    if (input.length == 0 || kc_isGzippedData(input)) {
        return input;
    }
    
    void *libz = dlopen("/usr/lib/libz.dylib", RTLD_LAZY);
    int (*deflateInit2_)(z_streamp, int, int, int, int, int, const char *, int) = dlsym(libz, "deflateInit2_");
    int (*deflate)(z_streamp, int) = dlsym(libz, "deflate");
    int (*deflateEnd)(z_streamp) = dlsym(libz, "deflateEnd");
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)input.length;
    stream.next_in = (Bytef *)input.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger KCGZipChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:KCGZipChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += KCGZipChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    dlclose(libz);
    
    return output;
}


@end
