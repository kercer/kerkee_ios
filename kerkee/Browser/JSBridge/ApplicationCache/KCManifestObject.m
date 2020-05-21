//
//  KCManifestObject.m
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import "KCManifestObject.h"
#import <KCBaseDefine.h>

@implementation KCManifestObject

-(KCURI*)manifestURI
{
    KCURI* uri = [[KCURI alloc] initWithString:self.mRelativePath relativeToURI:self.mBaseUri];
    KCAutorelease(uri);
    return uri;
}


@end
