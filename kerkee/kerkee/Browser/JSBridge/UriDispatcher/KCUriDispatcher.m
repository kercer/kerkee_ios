//
//  KCUriDispatcher.m
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCUriDispatcher.h"
#import "KCBaseDefine.h"
#import "KCSingleton.h"
#import "KCUriRegister.h"

@interface KCUriDispatcher ()
{
    NSString* m_defaultScheme;
    
    //the key is scheme, the value is KCUriRegister
    NSMutableDictionary* m_uriRgisterMap;
}

AS_SINGLETON(KCUriDispatcher);

@end



@implementation KCUriDispatcher

DEF_SINGLETON(KCUriDispatcher);


-(id)init
{
    if (self = [super init])
    {
        m_uriRgisterMap = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    KCRelease(m_uriRgisterMap);
    m_uriRgisterMap = nil;
    
    KCDealloc(super);
}

+(void)dispatcher:(NSString*)aUriString
{
    [[KCUriDispatcher sharedInstance] dispatcher:aUriString];
}

-(void)dispatcher:(NSString*)aUriString
{
    KCURI* uri = [KCURI parse:aUriString];
    if (uri)
    {
        id<KCUriRegisterDelegate> uriRegister = [self getUriRegister:uri.components.scheme];
        if (uriRegister)
            [uriRegister dispatcher:uri];
    }
}


#pragma mark -
#pragma mark KCUriRegister

/**
  before call defaultUriRegister,should set setDefaultScheme
  @param aScheme
 */

+(KCUriRegister*)markDefaultRegister:(NSString*)aScheme
{
   return  [[KCUriDispatcher sharedInstance] markDefaultRegister:aScheme];
}
-(KCUriRegister*)markDefaultRegister:(NSString*)aScheme
{
    KCUriRegister* uriRegister = nil;
    if (aScheme && aScheme.length > 0)
    {
        m_defaultScheme = aScheme;
        uriRegister = [self addUriRegisterWithScheme:aScheme];
    }
    return uriRegister;
}

+(KCUriRegister*)defaultUriRegister
{
   return [[KCUriDispatcher sharedInstance] defaultUriRegister];
}
-(KCUriRegister*)defaultUriRegister
{
    if (!m_defaultScheme || m_defaultScheme.length == 0)
        return nil;
        
    KCUriRegister* uriRegister = [m_uriRgisterMap objectForKey:m_defaultScheme];
    if (!uriRegister)
        [self markDefaultRegister:m_defaultScheme];
    return uriRegister;
}

+(KCUriRegister*)getUriRegisterWithScheme:(NSString*)aScheme
{
    return [[KCUriDispatcher sharedInstance] getUriRegisterWithScheme:aScheme];
}
-(KCUriRegister*)getUriRegisterWithScheme:(NSString*)aScheme
{
    KCUriRegister* uriRegister = nil;
    if (aScheme && aScheme.length > 0 && m_uriRgisterMap)
    {
        uriRegister = [m_uriRgisterMap objectForKey:aScheme];
    }
    return uriRegister;
}

+(KCUriRegister*)addUriRegisterWithScheme:(NSString*)aScheme
{
    return [[KCUriDispatcher sharedInstance] addUriRegisterWithScheme:aScheme];
}
-(KCUriRegister*)addUriRegisterWithScheme:(NSString*)aScheme
{
    KCUriRegister* uriRegister = nil;
    if (aScheme && aScheme.length > 0)
    {
        uriRegister = [[KCUriRegister alloc] initWithScheme:aScheme];
        [m_uriRgisterMap setObject:uriRegister forKey:aScheme];
    }
    return uriRegister;
}



#pragma mark -
#pragma mark id<KCUriRegisterDelegate>

+(id<KCUriRegisterDelegate>)getUriRegister:(NSString*)aScheme
{
    return [[KCUriDispatcher sharedInstance] getUriRegister:aScheme];
}
-(id<KCUriRegisterDelegate>)getUriRegister:(NSString*)aScheme
{
    if (!aScheme || aScheme.length==0) return nil;
    id<KCUriRegisterDelegate> uriRegister = [m_uriRgisterMap objectForKey:aScheme];
    
    return uriRegister;
}

+(BOOL)addUriRegister:(id<KCUriRegisterDelegate>)aUriRegisterDelegate
{
    return [[KCUriDispatcher sharedInstance] addUriRegister:aUriRegisterDelegate];
}
-(BOOL)addUriRegister:(id<KCUriRegisterDelegate>)aUriRegisterDelegate
{
    if (aUriRegisterDelegate)
    {
        if ([aUriRegisterDelegate respondsToSelector:@selector(scheme)])
        {
            NSString* scheme = [aUriRegisterDelegate scheme];
            if (scheme && scheme.length > 0)
            {
                [m_uriRgisterMap setObject:aUriRegisterDelegate forKey:scheme];
                return true;
            }
        }
        
    }
    return false;
}


@end
