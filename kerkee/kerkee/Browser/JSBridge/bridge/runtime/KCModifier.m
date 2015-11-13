//
//  KCModifier.m
//  kerkee
//
//  Created by zihong on 15/11/12.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCModifier.h"

#define PUBLIC 0x1
#define PRIVATE 0x2
#define STATIC 0x4

@interface KCModifier ()
{
    int m_modifier;
}

@end

@implementation KCModifier


- (id)init
{
    if (self = [super init])
    {
        m_modifier = 0;
    }
    return self;
}

- (void)markStatic
{
    m_modifier = m_modifier | STATIC;
}

- (void)markPublic
{
    m_modifier = m_modifier | PUBLIC;
}
- (void)markPrivate
{
    m_modifier = m_modifier | PRIVATE;
}

- (BOOL)isEqual:(KCModifier*)aModifier
{
    return m_modifier == aModifier->m_modifier;
}

+ (int)methodModifiers
{
    return PUBLIC | PRIVATE | STATIC;
}

- (BOOL)isStatic
{
    return ((m_modifier & STATIC) != 0);
}

- (int)getModifiers
{
    return m_modifier;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%d",m_modifier];
}

@end
