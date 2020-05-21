//
//  KCModifier.h
//  kerkee
//
//  Created by zihong on 15/11/12.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KCModifier : NSObject

- (void)markStatic;
- (void)markPublic;
- (void)markPrivate;

- (BOOL)isEqual:(KCModifier*)aModifier;

+ (int)methodModifiers;
- (BOOL)isStatic;
- (int)getModifiers;

@end
