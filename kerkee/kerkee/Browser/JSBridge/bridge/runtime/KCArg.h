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

+ (id)newArgWithObject:(id)aValue name:(NSString*)aName;

- (id)initWithObject:(id)aValue name:(NSString *)aName;
- (NSString *)getArgName;
- (id)getValue;
- (Class)getType;
- (NSString *)toString;
@end
