//
//  KCUriRegister.h
//  kerkee
//
//  Created by zihong on 15/9/16.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCUriActionDelegate.h"
#import "KCURI.h"

//must realize thes interface
@protocol KCUriRegisterDelegate <NSObject>

-(BOOL) registerAction:(id<KCUriActionDelegate>)aAction;
-(BOOL) unregisterAction:(id<KCUriActionDelegate>)aAction;
-(void) dispatcher:(KCURI*)aUriData;
-(NSString*) scheme;

@end


@interface KCUriRegister : NSObject <KCUriRegisterDelegate>

@property (nonatomic, readonly) NSString* scheme;

-(id)initWithScheme:(NSString*)aScheme;

-(BOOL)containsAction:(id<KCUriActionDelegate>)aAction;

@end
