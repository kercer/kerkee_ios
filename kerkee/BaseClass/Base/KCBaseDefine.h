//
//  KCBaseDefine.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#ifndef KerCer_KCBaseDefine_h
#define KerCer_KCBaseDefine_h

#if __OBJC__
#  import <Foundation/Foundation.h>
#endif

#if ! __has_feature(objc_arc)
    #define KCAutorelease(__v) ([__v autorelease]);
    #define KCReturnAutoreleased KCAutorelease

    #define KCRetain(__v) ([__v retain]);
    #define KCReturnRetained KCRetain

    #define KCRelease(__v) ([__v release]);

    #define KCDealloc(__v) ([__v dealloc]);
#else
    // -fobjc-arc
    #define KCAutorelease(__v)
    #define KCReturnAutoreleased(__v) (__v)

    #define KCRetain(__v)
    #define KCReturnRetained(__v) (__v)

    #define KCRelease(__v) ([__v class])

    #define KCDealloc(__v) ([__v class])
#endif


#undef KC_weak
#if __has_feature(objc_arc_weak)
#define KC_weak weak
#else
#define KC_weak unsafe_unretained
#endif



// ----------------------------------
// Option values
// ----------------------------------

#undef	__ON__
#define __ON__		(1)

#undef	__OFF__
#define __OFF__		(0)

#undef	__AUTO__

#if defined(_DEBUG) || defined(DEBUG)
#define __AUTO__	(1)
#else
#define __AUTO__	(0)
#endif

// ----------------------------------
// Global compile option
// ----------------------------------
#define __KC_MODLE_DEV__				(__OFF__)
#define __KC_MODLE_TEST__				(__OFF__)

#define __KC_LOG__						(__OFF__)
#define __KC_LOG__Brief__               (__OFF__)
#define __KC_LOG__FILE__			    (__OFF__)

#pragma mark -
#if defined(__KC_LOG__) && __KC_LOG__
#undef	NSLog
#define	NSLog	KCLog
#endif	// #if (__ON__ == __KC_LOG__)


/*
 [{"clz":"XMLHttpRequest","method":"create","args":{"id":4}},{"clz":"XMLHttpRequest","method":"overrideMimeType","args":{"id":4,"mimetype":"application/json"}},{"clz":"XMLHttpRequest","method":"open","args":{"id":4,"method":"get","url":"http://api.k.sohu.com/api/comment/getHotCommentListByCursor.go?busiCode=2&apiVersion=29&channelId=1&cursorId=-1&from=channel&gid=-1&id=63414345&newsId=63414345&openType=0&p1=NTk0MTQ4MTE4OTU4NzQ2NDI2MQ&u=5&page=1&pid=-1&position=5&refer=3&rollType=2&rt=json&size=10&source=news&type=2","scheme":"file:","host":"","port":"","href":"file:///Users/lijian/Library/Developer/CoreSimulator/Devices/51BFE10E-5838-4283-955A-CDA76221C9E6/data/Containers/Data/Application/27131B8B-1848-4E37-9EC8-2BC0038CFD44/Documents/html/modules/article/article.html","referer":null,"useragent":"Mozilla/5.0 (iPhone; CPU iPhone OS 8_4 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12H141","cookie":"IPLOC=CN1100; localChannelInfo=%5B%7B%22appointUrl%22%3A%22https%3A//itunes.apple.com/cn/app/sou-hu-shi-pin-gao-qing/id458587755%3Fmt%3D8%22%2C%22startapp%22%3A%220%22%2C%22channelSrc%22%3A0%2C%22cover%22%3A1%2C%22isClosed%22%3A0%2C%22timeLimit%22%3A0%2C%22channelNum%22%3A680%2C%22cid%22%3A%22%22%2C%22quality%22%3A%22nor%2Chig%2Csup%22%2C%22time%22%3A1438581216617%7D%5D; SUV=1507311832261595","async":true}},{"clz":"XMLHttpRequest","method":"setRequestHeader","args":{"id":4,"headerName":"Accept","headerValue":"application/json"}},{"clz":"XMLHttpRequest","method":"setRequestHeader","args":{"id":4,"headerName":"SCOOKIE"}},{"clz":"XMLHttpRequest","method":"send","args":{"id":4}}]
 */
////暂时把kclog修改为nslog 为解决[text utf8String]不能解析部分数据的问题
//#pragma mark -
//#if defined(__KC_LOG__) && __KC_LOG__
//#undef	KCLog
//#define	KCLog	NSLog
//#endif	// #if (__ON__ == __KC_LOG__)





/**
 * Make global functions usable in C++
 */
#if defined(__cplusplus)
#define KC_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define KC_EXTERN extern __attribute__((visibility("default")))
#endif

/**
 * By default, only raise an NSAssertion in debug mode
 * (custom assert functions will still be called).
 */
#ifndef KC_NSASSERT
#if __KC_LOG__
#define KC_NSASSERT 1
#else
#define KC_NSASSERT 0
#endif
#endif

/**
 * Throw an assertion for unimplemented methods.
 */
#define KC_NOT_IMPLEMENTED(method) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmissing-method-return-type\"") \
_Pragma("clang diagnostic ignored \"-Wunused-parameter\"") \
KC_EXTERN NSException *_KCNotImplementedException(SEL, Class); \
method NS_UNAVAILABLE { @throw _KCNotImplementedException(_cmd, [self class]); } \
_Pragma("clang diagnostic pop")


#import "KCLog.h"

#endif
