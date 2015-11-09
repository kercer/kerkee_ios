//
//  KCJSObject.h
//  kerkee
//
//  Created by zihong on 15/11/9.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KCJSObject <NSObject>

- (NSString*)getJSObjectName;

@end

@interface KCJSObject : NSObject <KCJSObject>


@end
