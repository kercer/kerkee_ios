//
//  SHUrlMaping.m
//  LiteSohuNews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCUrlMaping.h"

NSString * const kHomeId = @"1";
NSString * const kPicsId = @"47";
NSString * const kLiveId = @"25";
NSString * const kQiquId = @"54";

@interface KCUrlMaping() {
    
}
@property (nonatomic, strong) NSData *data;

@end

@implementation KCUrlMaping

- (id)init
{
    self = [super init];
    if(nil != self){
        _data = [self getData];
    }
    return self;
}

+ (KCUrlMaping *)shareInstance
{
    static KCUrlMaping *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[KCUrlMaping alloc] init];
    });
    
    return instance;
}

+ (NSDictionary *)getUrlMaping
{
    KCUrlMaping *map = [KCUrlMaping shareInstance];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if(nil != map.data && [map.data length] > 0){
        NSString *content = [[NSString alloc] initWithData:map.data encoding:NSUTF8StringEncoding];
        NSString *key = nil;
        NSMutableString *value = nil;

        NSArray *array = [content componentsSeparatedByString:@"\n"];
        for (NSString *temp in array) {
            if(nil == temp || [temp length] <= 0 || [temp isEqualToString:@""]){
                continue;
            }
            
            NSRange range = [temp rangeOfString:@"#"];
            if(range.length > 0){
                continue;
            }
            
            NSArray *keyArray = [temp componentsSeparatedByString:@"/"];
            key = nil;
            value = [NSMutableString string];
            if(nil != keyArray && [keyArray count] >= 2){
                for (NSString *obj in keyArray) {
                    if(nil == obj || [obj length] <= 0 || [obj isEqualToString:@""]){
                        continue;
                    }
                    if(nil == key){
                        key = obj;
                        key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        continue;
                    }
                    
                    [value appendFormat:@"/%@",obj];
                }
                [dic setObject:value forKey:key];
            }
        }
    }
    
    return dic;
}


- (NSData *)getData
{
    //NSString *url = SH_URLMAPING_PATH;
    NSLog(@"MapPath:%@",SH_URLMAPING_PATH);
//    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:SH_URLMAPING_PATH isDirectory:&isDirectory]) {
//        //return nil;
//    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:SH_URLMAPING_PATH]];
    return data;
}

+ (NSString *)getRelativePathWithKey:(NSString *)key
{
    if(nil == key && [key length] <= 0)
        return nil;
    
    NSDictionary *dic = [self getUrlMaping];
    
    NSArray *keys = [dic allKeys];
    
    for (NSString *temp in keys) {
        if(nil != temp && [temp length] > 0 && [temp isEqualToString:key]){
            return [dic objectForKey:key];
        }
    }
    
    return nil;
}

+ (NSString *)getLocalPathWithKey:(NSString *)key
{
    if(nil == key && [key length] <= 0)
        return nil;
    
    NSString *path = [self getRelativePathWithKey:key];
    if(nil != path){
        return [KCWebPath_HtmlRootPath stringByAppendingString:path];
    }
    
    return nil;
}

+ (NSString *)getRelativePathWithChannelID:(NSString *)channelID {
    NSString *relativePath = nil;
    // 不同的频道需要加载不同的模板
    if ([channelID isEqualToString:kHomeId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_HOME];
    } else if ([channelID isEqualToString:kPicsId] || [channelID isEqualToString:kQiquId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSPICS];
    } else if ([channelID isEqualToString:kLiveId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSLIVE];
    } else {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSLIST];
    }
    return relativePath;
}

@end
