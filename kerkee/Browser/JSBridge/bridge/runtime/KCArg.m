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
#import "KCJSType.h"

@interface KCArg()
{
    NSString* m_name;
    id m_Object;
    Class m_type;
}

@end

@implementation KCArg

+ (id)newArgWithObject:(id)aValue name:(NSString*)aName
{
    return [[KCArg alloc] initWithObject:aValue name:aName];
}

- (id)initWithObject:(id)aValue name:(NSString *)aName
{
    if (self = [super init])
    {
        m_name = aName;
        m_Object = aValue;
        m_type = [aValue class];
    }
    return self;
}

- (void)dealloc
{
    m_name = nil;
    m_Object  = nil;
    
    KCDealloc(super);
}


- (NSString *)getArgName
{
    return m_name;
}

- (id)getValue
{
    return m_Object;
}

- (Class)getType
{
    return m_type;
}

- (NSString*)toString
{
    return [self description];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@:%@",m_name, [m_Object description]];
}

@end
