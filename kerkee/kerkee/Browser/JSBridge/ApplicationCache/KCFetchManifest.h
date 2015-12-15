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

#pragma mark - fetch server manifest
//fetch one manifest file from server
+ (void)fetchOneServerManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;
//fetch all association manifest from server
+ (void)fetchServerManifests:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;

#pragma mark - fetch local manifest
//fetch one manifest file from local
+ (KCManifestObject*)fetchOneLocalManifest:(KCURI*)aUri;
+ (void)fetchOneLocalManifest:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;
//fetch all association manifest from local
+ (void)fetchLocalManifests:(KCURI*)aUri block:(void(^)(KCManifestObject* aManifestObject))aBlock;


@end
