//
//  KCArglist.h
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArg.h"


@interface KCArgList : NSObject

- (BOOL) addArg:(KCArg *)aArg;
- (id) getArgValule:(NSString *)aKey;
- (NSString *)getArgValueString:(NSString *)aKey;
- (NSString *)toString;
- (NSInteger)count;

@end
