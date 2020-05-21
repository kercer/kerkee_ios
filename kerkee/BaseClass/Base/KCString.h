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

- (BOOL)kc_startsWithChar:(char)aChar;
- (BOOL)kc_startsWith:(NSString *)aPrefix;
- (BOOL)kc_endsWith:(NSString *)aSuffix;
- (BOOL)kc_isEmpty;
- (NSString *)kc_trim:(NSString *)aString;
- (int)kc_indexOf:(NSString*)aSearch;
- (int)kc_indexOf:(NSString*)aSearch startIndex:(NSUInteger)aStartIndex;
- (int)kc_indexOfChar:(char)aChar;
- (int)kc_lastIndexOfChar:(char)aChar;
- (int)kc_lastIndexOf:(NSString*)aSearch;
- (NSString*)kc_replaceChar:(char)aOldChar withChar:(char)aNewChar;
- (NSString *)kc_replaceAll:(NSString*)aTarget with:(NSString*)aWith;
- (NSString *)kc_substring:(NSUInteger)aStart;
- (NSString *)kc_substring:(NSUInteger)aStart end:(NSUInteger)aEnd;
- (BOOL)kc_equals:(NSString*)aString;

@end
