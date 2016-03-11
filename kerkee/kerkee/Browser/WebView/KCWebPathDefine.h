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
#define KCWebPath_HtmlRootPath_ZipFile      [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html.zip"]


//test
#define KCWebPath_ModulesTest_File       [KCWebPath_HtmlRootPath stringByAppendingPathComponent:@"modules/test/test.html"]


#endif
