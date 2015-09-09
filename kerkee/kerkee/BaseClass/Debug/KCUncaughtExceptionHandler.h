//
//  KCUncaughtExceptionHandler.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCUncaughtExceptionHandler : NSObject
{
	BOOL dismissed;
}

@end
void HandleException(NSException *exception);
void SignalHandler(int signal);


void InstallUncaughtExceptionHandler(void);
