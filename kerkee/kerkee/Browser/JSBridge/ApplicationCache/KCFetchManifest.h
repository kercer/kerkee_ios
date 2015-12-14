//
//  KCFetchManifest.h
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCURI.h"
#import "KCManifestObject.h"

@interface KCFetchManifest : NSObject

+ (void)fetchOneServerManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;

+ (void)fetchServerManifests:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;

+ (KCManifestObject*)fetchOneLocalManifest:(KCURI*)aUri;
+ (void)fetchOneLocalManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;



@end
