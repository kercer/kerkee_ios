//
//  KCFetchManifest.h
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCURI.h"

@interface KCFetchManifest : NSObject

+ (void)fetchOneServerManifest:(KCURI*)aUri;

@end
