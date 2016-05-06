//
//  KCApiJSObjExample.h
//  kerkeeDemo
//
//  Created by zihong on 2015-11-10.
//  Copyright © 2015 zihong. All rights reserved.
//

#import <kerkee.h>

@interface KCApiJSObjExample : KCJSObject

-(void)objExampleNotStaticFunction:(KCWebView*)aWebView argList:(KCArgList*)args;
+(void)objExampleStaticFunction:(KCWebView*)aWebView argList:(KCArgList*)args;

@end
