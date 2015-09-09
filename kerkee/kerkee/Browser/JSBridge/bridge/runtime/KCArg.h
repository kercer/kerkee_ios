//
//  KCArg.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCArg : NSObject


+ (id)initWithObject:(id)obj key:(NSString *)key;
- (id)getValue;
- (NSString *)getArgName;
- (NSString *)toString;
@end
