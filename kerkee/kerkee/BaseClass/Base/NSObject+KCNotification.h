//
//  NSObject+KCNotification.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>


#pragma mark -

#define AS_NOTIFICATION( __name )	AS_STATIC_PROPERTY( __name )
#define DEF_NOTIFICATION( __name )	DEF_STATIC_PROPERTY3( __name, @"notify", [self description] )

#pragma mark -

@interface NSNotification(KCNotification)

- (BOOL)is:(NSString *)name;
- (BOOL)isKindOf:(NSString *)prefix;

@end

#pragma mark -

@interface NSObject(KCNotification)

+ (NSString *)NOTIFICATION;

- (void)handleNotification:(NSNotification *)notification;

- (void)observeNotification:(NSString *)name;
- (void)unobserveNotification:(NSString *)name;
- (void)unobserveAllNotifications;

- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSString *)aName;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
