//
//  KCWebPathDefine.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#ifndef kerkee_KCWebPathDefine_h
#define kerkee_KCWebPathDefine_h


#define KCWebPath_ONLINE_TESTMODE   (0)
#define KCWebPath_ONLINE_TESTHOST   (@"http://10.0.69.79:3001")

//root
#define KCWebPath_HtmlRootPath              (KCWebPath_ONLINE_TESTMODE > 0)?(KCWebPath_ONLINE_TESTHOST):([@"file://" stringByAppendingString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"]])
#define KCWebPath_HtmlLocalPath             ([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"])

//zip files
#define KCWebPath_HtmlRootPath_PLIST        [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/version.plist"]
#define KCWebPath_HtmlRootPath_ZipFile      [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html.zip"]

//images
#define KCWebPath_ImagesPath                [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"cache/webimages"]

//bridge lib
#define KCWebPath_BridgeLibPath_File        [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"attach/js/bridgeLib.js"]

//config
#define KCWebPath_ConfigPath_File           [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"conf/urlmapping.conf"]

//应用类的html
#define KCWebPath_ModulesChannel_File       [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/channel/channel.html"]//一般频道
#define KCWebPath_ModulesLiveChannel_File   [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/live/live.html"]//直播频道
#define KCWebPath_ModulesPicsChannel_File   [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/pics/pics.html"]//美图频道

// 搜索本地路径
#define KCWebPath_ModulesSearch_File        [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/search/search.html"]


//test
#define KCWebPath_ModulesTest_File       [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/test/test.html"]


#endif
