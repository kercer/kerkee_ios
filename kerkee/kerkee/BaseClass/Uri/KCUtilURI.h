//
//  KCUtilURI.h
//  kerkee
//
//  Created by zihong on 15/12/14.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCUtilURI : NSObject

/**
 * TODO refactor this algorithm, it's a bit chunky and not so readable
 *
 * @param aPath
 * @return
 */
+ (NSString*) removeDotSegments:(NSString*)aPath;

@end
