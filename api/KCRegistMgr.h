//
//  KCRegistMgr.h
//  sohunews
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KCRegistObj:NSObject

@property (nonatomic, copy) NSString *interfaceName;
@property (nonatomic, weak) id instanceObj;

@end

@interface KCRegistMgr : NSObject

+ (void)registAllClass;

+ (id)shareInstance;
- (void)registJSInterface:(NSString *)interfaceName obj:(id)instanceObj;
- (void)unRegistJSInterface:(NSString *)interfaceName obj:(id)instanceObj;

@end
