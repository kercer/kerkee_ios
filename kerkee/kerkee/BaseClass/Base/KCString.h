//
//  KCString.h
//  kerkee
//
//  Created by zihong on 15/12/14.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCString : NSObject

+ (int)lastIndexOfChar:(char)aChar str:(NSString*)aString;

@end

@interface NSString(KCStringAdditions)

- (BOOL)startsWithChar:(char)aChar;
- (BOOL)startsWith:(NSString *)aPrefix;
- (BOOL)endsWith:(NSString *)aSuffix;
- (BOOL)isEmpty;
- (NSString *)trim:(NSString *)aString;
- (int)indexOf:(NSString*)aSearch;
- (int)indexOf:(NSString*)aSearch startIndex:(NSUInteger)aStartIndex;
- (int)indexOfChar:(char)aChar;
- (int)lastIndexOfChar:(char)aChar;
- (int)lastIndexOf:(NSString*)aSearch;
- (NSString*)replaceChar:(char)aOldChar withChar:(char)aNewChar;
- (NSString *)replaceAll:(NSString*)aTarget with:(NSString*)aWith;
- (NSString *)substring:(NSUInteger)aStart;
- (NSString *)substring:(NSUInteger)aStart end:(NSUInteger)aEnd;
- (BOOL) equals:(NSString*)aString;

@end
