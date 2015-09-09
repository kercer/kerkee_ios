//
//  KCArg.m
//  kerkee
//
//  Designed by zihong
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCArg.h"
#import "KCBaseDefine.h"

@interface KCArg()

@property (nonatomic, copy)     NSString *mName;
@property (nonatomic, retain)   id mObject;
@end

@implementation KCArg

+ (id)initWithObject:(id)obj key:(NSString *)key
{
    KCArg *arg = [[self alloc] init];
    
    arg.mName = key;
    arg.mObject = obj;

    KCAutorelease(arg);
    return arg;
}

- (id)getValue
{
    return self.mObject;
}


- (NSString *)getArgName
{
    return self.mName;
}


- (NSString *)toString
{
    NSString *objString = ([self.mObject isKindOfClass:[NSString class]])?(self.mObject):( NSStringFromClass([self.mObject class]));
    return [NSString stringWithFormat:@"%@:%@",self.mName,objString];
}

- (void)dealloc
{
    self.mObject = nil;
    self.mName  = nil;
    
    KCDealloc(super);
}

@end
