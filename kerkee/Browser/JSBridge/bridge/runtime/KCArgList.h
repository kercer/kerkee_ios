//
//  KCArgList.h
//  kerkee
//
//  Created by zihong on 15/11/16.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCArg.h"
#import "KCJSCallback.h"


@interface KCArgList : NSObject

- (BOOL)addArg:(KCArg *)aArg;
- (BOOL)has:(NSString*)aKey;
- (id)getArgValule:(NSString*)aKey __attribute__((deprecated("use 'getObject:' in deepContent instead")));;
- (id)getObject:(NSString *)aKey;
- (NSString*)getString:(NSString*)aKey;
- (KCJSCallback*)getCallback;
- (BOOL)getBoolean:(NSString*)aKey;
- (NSString *)toString;
- (NSInteger)count;

@end
