//
//  KCUriActionDelegate.h
//  kerkee
//
//  Created by zihong on 15/9/10.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#ifndef kerkee_KCUriActionDelegate_h
#define kerkee_KCUriActionDelegate_h

#import <Foundation/Foundation.h>

@protocol KCUriActionDelegate <NSObject>

/**
 * Determine whether to perform custom operations protocol,if accept return true,else return false.
 */
-(BOOL) accept:(NSString*)aHost path:(NSString*)aPath;

/**
 * if accept function return true,invokeAction can be called,you call do something here
 */
-(void) invokeAction:(NSDictionary*)aParams;



@end



#endif
