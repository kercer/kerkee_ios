//
//  KCDirWatcher.h
//  kerkee
//
//  Object used to monitor the contents of a given directory
//  by using "kqueue": a kernel event notification mechanism.
//
//  Created by zihong on 16/3/30.
//  Copyright (c) 2016年 zihong. All rights reserved.
//


#import <Foundation/Foundation.h>

@class KCDirWatcher;

@protocol KCDirWatcherDelegate <NSObject>
@required
- (void)directoryDidChange:(KCDirWatcher *)aWatcher;
@end

@interface KCDirWatcher : NSObject
@property (nonatomic, weak) id <KCDirWatcherDelegate> delegate;

+ (KCDirWatcher *)watchDirWithPath:(NSString *)aWatchPath delegate:(id<KCDirWatcherDelegate>)aWatchDelegate;
- (void)stop;
@end
