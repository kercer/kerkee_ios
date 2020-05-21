//
//  KCUriRegister.m
//  kerkee
//
//  Created by zihong on 15/9/16.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCUriRegister.h"
#import "KCBaseDefine.h"

@interface KCUriRegister ()
{
    NSString* m_scheme;
    //the value is id<KCUriActionDelegate>
    NSMutableArray* m_uriActions;
}

@end

@implementation KCUriRegister
@synthesize scheme = m_scheme;

-(id)initWithScheme:(NSString*)aScheme
{
    self = [self init];
    if (self)
    {
        m_scheme = aScheme;
    }
    
    return self;
}

-(id) init
{
    if (self = [super init])
    {
        m_uriActions = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}


-(void) dealloc
{
    KCRelease(m_uriActions);
    m_uriActions = nil;
    
    KCRelease(m_scheme);
    m_scheme = nil;
    
    KCDealloc(super);
}


-(BOOL) containsAction:(id<KCUriActionDelegate>)aAction
{
    return (aAction && [m_uriActions containsObject:aAction]);
}

#pragma mark KCUriRegisterDelegate
-(BOOL) registerAction:(id<KCUriActionDelegate>)aAction
{
    if (aAction && ![m_uriActions containsObject:aAction])
    {
        [m_uriActions addObject:aAction];
        return true;
    }
    return false;
}

-(BOOL) unregisterAction:(id<KCUriActionDelegate>)aAction
{
    if (aAction && [m_uriActions containsObject:aAction])
    {
        [m_uriActions removeObject:aAction];
        return true;
    }
    return false;
}

-(void) dispatcher:(KCURI*)aUriData
{
    NSUInteger count = [m_uriActions count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        id<KCUriActionDelegate> action = [m_uriActions objectAtIndex:i];
        if ([action accept:aUriData.components.host path:aUriData.components.path])
        {
            [action invokeAction:[aUriData getQueries]];
            break;
        }
    }
}

-(NSString*) scheme
{
    return m_scheme;
}


@end
