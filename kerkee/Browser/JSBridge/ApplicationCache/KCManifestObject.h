//
//  KCManifestObject.h
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCObject.h"
#import "KCURI.h"

@interface KCManifestObject : KCObject


@property (nonatomic, retain) NSString* mVersion;// version
@property (nonatomic, retain) NSArray* mSubManifests;// sub manifests list
@property (nonatomic, retain) NSArray* mExtras; //extras files, don't delete files
@property (nonatomic, retain) NSArray* mCacheList;
@property (nonatomic, retain) NSString* mDekRelativePath; //dek relative to manifest path, if dek path is url, it's null
@property (nonatomic, retain) NSString* mRequiredVersion; //required version;
@property (nonatomic, retain) NSArray* mCacheDirs;//cache dirs, contains mCacheList' dir, not contains Extras and suManifests dir

//if mDekRelativePath's scheme is not null, set it in Parser
//if from server,set it in KCFetchManifest;
//if from local,set it in KCManifestParser
@property (nonatomic, retain) NSString* mDownloadUrl;
//dek & manifest file Dir, if from server, the VAR is null
@property (nonatomic, retain) NSString* mDestDir;

@property (nonatomic, retain) KCURI* mBaseUri;  //root uri
@property (nonatomic, retain) NSString* mRelativePath; //relative to base uri

-(KCURI*)manifestURI;

@end
