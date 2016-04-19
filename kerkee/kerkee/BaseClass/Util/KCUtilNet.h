//
//  KCUtilNet.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface KCUtilNet : NSObject


+ (BOOL) IsEnableWIFI;
+ (BOOL) IsEnable3G;

+(BOOL)hasNetwork;

+(NetworkStatus)networkStatus;
+(NSString*)networkStatusToString;

+(NSString*)getCarrier:(NSString*)aIMSI;


@end
