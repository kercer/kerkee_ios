//
//  KCUtilCoding.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilCoding.h"
#import "KCBaseDefine.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation KCUtilCoding



+ (NSString *)encodeToPercentEscapeString: (NSString *) input  
{
    return [self encodeToPercentEscapeString:input encoding:kCFStringEncodingUTF8];
}

+ (NSString *)encodeToPercentEscapeString: (NSString *)input encoding:(CFStringEncoding)encoding
{
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                 (CFStringRef)input,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                 encoding));
    return outputStr;
}

/*!	Decode a URL's query-style string, taking out the + and %XX stuff
 */
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input  
{  
    NSMutableString *outputStr = [NSMutableString stringWithString:input];  
    [outputStr replaceOccurrencesOfString:@"+"  
                               withString:@" "  
                                  options:NSLiteralSearch  
                                    range:NSMakeRange(0, [outputStr length])];  
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
}



+ (NSString*) encodeUseBase64:(NSData *)data
{
    static char base64EncodingTable[64] =
    {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
    };
    NSUInteger length = [data length];
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true)
    {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++)
        {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining)
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }     
    return result;
}



+ (NSData*) decodeUseBase64:(NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[4];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil) {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true) {
        if (ixtext >= lentext){
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4) {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return theData;
}




#pragma mark conver

+(NSString *) parseByteArrayToHexString:(NSData *) data
{
   return [self parseByteArrayToHexString:(Byte*)[data bytes] length:[data length]];
}

+(NSString *) parseByteArrayToHexString:(Byte *) bytes length:(NSUInteger)length
{
    NSMutableString *hexStr = [[NSMutableString alloc] init];
    int i = 0;
    if(bytes)
    {
        while (i<length)
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    KCAutorelease(hexStr);
    return [hexStr uppercaseString];
}


+(NSData*) parseHexToByteArray:(NSString*) hexString
{
    int j=0;
    Byte bytes[hexString.length];
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:hexString.length/2];
    KCAutorelease(newData);
    return newData;
}




#pragma mark des
+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey
{
    return [self encryptUseDES:aPlainText key:aKey iv:nil];
}

+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey iv:(Byte*)aIV
{
   return [self encryptUseDES:aPlainText key:aKey iv:aIV encodeBlock:^NSString *(NSData *data) {
       return [self parseByteArrayToHexString:(Byte*)[data bytes] length:[data length]];
    }];
}

+(NSString *) encryptUseDES:(NSString *)aPlainText key:(NSString *)aKey iv:(Byte*)aIV encodeBlock:(blockEncode)aBlockEncode
{
    NSString *ciphertext = nil;
    NSData *textData = [aPlainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];

    size_t numBytesEncrypted = 0;
    size_t dataOutAvailable = 0;
    dataOutAvailable = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    unsigned char buffer[dataOutAvailable];
    memset(buffer, 0, dataOutAvailable*sizeof(char));
    
    Byte* pIV = nil;
    Byte ivTmp[8];
    memset(ivTmp, 0, sizeof(Byte)*sizeof(ivTmp));
    pIV = aIV ? aIV :ivTmp;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [aKey UTF8String], kCCKeySizeDES,
                                          pIV,
                                          [textData bytes]  , dataLength,
                                          buffer, dataOutAvailable,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
//        KCLog(@"DES encrypt success");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = aBlockEncode(data);
    }
    else
    {
        KCLog(@"DES encrypt fail");
    }
    return ciphertext;

}


+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey
{
    return [self decryptUseDES:aCipherText key:aKey iv:nil];
}

+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey iv:(Byte*)aIV
{
    return [self decryptUseDES:aCipherText key:aKey iv:aIV decodeBlock:^NSData *(NSString *string) {
       return [self parseHexToByteArray:string];
    }];
}


+(NSString *) decryptUseDES:(NSString *)aCipherText key:(NSString *)aKey iv:(Byte*)aIV decodeBlock:(blockDecode)aBlockDecode
{
    NSString *cleartext = nil;
    NSData *textData = aBlockDecode(aCipherText);
    if (!textData) return cleartext;
    NSUInteger dataLength = [textData length];
    
    
    size_t dataOutAvailable = 0;
    dataOutAvailable = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    unsigned char buffer[dataOutAvailable];
    memset(buffer, 0, dataOutAvailable*sizeof(char));
    size_t numBytesEncrypted = 0;
    
    Byte* pIV = nil;
    Byte ivTmp[8];
    memset(ivTmp, 0, sizeof(Byte)*sizeof(ivTmp));
    pIV = aIV ? aIV :ivTmp;
    
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [aKey UTF8String], kCCKeySizeDES,
                                          pIV,
                                          [textData bytes]  , dataLength,
                                          buffer, dataOutAvailable,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
//        KCLog(@"DES decrypt success");
        
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        KCAutorelease(cleartext);
    }
    else
    {
        KCLog(@"DES decrypt fail");
    }
    return cleartext;

}


+ (NSString*) convertDataToHex: (NSData*)data
{
	NSString *hexString = [NSMutableString stringWithCapacity:data.length * 2];
	const unsigned char *buffer = (const unsigned char *)[data bytes];
    
	for (int i = 0; i < data.length; i++)
    {
		hexString = [hexString stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
	}
    
	return hexString;
}

unsigned char charsToByte(const char high, const char low)
{
	char nybbles[3] = { high, low, '\0' };
	return (unsigned char)strtol(nybbles, NULL, 16);
}

+ (NSData*) convertHexToData: (NSString*)str
{
    
	const char* asciiStr = [str UTF8String];
	NSMutableData *hexData = [NSMutableData dataWithCapacity:str.length / 2];
    
	for (int i = 0; i < str.length; i += 2)
    {
		unsigned char byte = charsToByte(asciiStr[i], asciiStr[i + 1]);
		[hexData appendBytes:&byte length: 1];
	}
    
	return hexData;
}


+ (NSString *) hmacSha1:(NSString*)key text:(NSString*)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}




@end
