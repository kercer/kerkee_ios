//
//  SHUrlMaping.h
//  LiteSohuNews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kerkee.h"

#define SH_URLMAPING_FILENAME                   (@"conf/urlmapping.conf")
#define SH_URLMAPING_PATH                       ([KCWebPath_HtmlRootPath stringByAppendingPathComponent:SH_URLMAPING_FILENAME])

//业务相关的内容
#define SH_JSURL_ARTICLE                        (@"article.html")
#define SH_JSURL_CHANNEL                        (@"channel.html")
#define SH_JSURL_CHANNELLIST                    (@"channelList.html")
#define SH_JSURL_HOME                           (@"home.html")
#define SH_JSURL_LIVE                           (@"live.html")
#define SH_JSURL_MEDIA                          (@"media.html")
#define SH_JSURL_NEWSLIST                       (@"newsList.html")
#define SH_JSURL_NEWSLIVE                       (@"newsLive.html")
#define SH_JSURL_NEWSPICS                       (@"newsPics.html")
#define SH_JSURL_PICS                           (@"pics.html")
#define SH_JSURL_SEARCH                         (@"search.html")
#define SH_JSURL_SPECIAL                        (@"special.html")

@interface KCUrlMaping : NSObject

+ (NSDictionary *)getUrlMaping;
+ (NSString *)getRelativePathWithKey:(NSString *)key;
+ (NSString *)getRelativePathWithChannelID:(NSString *)channelID;
+ (NSString *)getLocalPathWithKey:(NSString *)key;

@end
