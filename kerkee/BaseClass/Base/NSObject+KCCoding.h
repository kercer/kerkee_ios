//
//  NSObject+KCCoding.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>


@interface NSObject (KCCoding)

#pragma mark -
- (void)encodeAutoWithCoder:(NSCoder *)aCoder;
- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder;
- (void)encodeAutoWithCoder:(NSCoder *)aCoder class:(Class)cls;
- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder class:(Class)cls;

@end
