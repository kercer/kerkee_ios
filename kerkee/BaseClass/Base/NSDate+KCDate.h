//
//  NSDate+KCDate.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate (KCDate)

# pragma mark -
# pragma mark Relative dates
+ (NSDate *) kc_dateTomorrow;
+ (NSDate *) kc_dateYesterday;
+ (NSDate *) kc_dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) kc_dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) kc_dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) kc_dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) kc_dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) kc_dateWithMinutesBeforeNow: (NSInteger) dMinutes;

+ (NSDate *) kc_dateWithTimestamp:(unsigned long long) aTimestamp;

# pragma mark Comparing dates
- (BOOL) kc_isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) kc_isSameDayAsDate: (NSDate *) aDate;
- (BOOL) kc_isToday;
- (BOOL) kc_isTomorrow;
- (BOOL) kc_isYesterday;
- (BOOL) kc_isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) kc_isThisWeek;
- (BOOL) kc_isNextWeek;
- (BOOL) kc_isLastWeek;
- (BOOL) kc_isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) kc_isThisMonth;
- (BOOL) kc_isSameYearAsDate: (NSDate *) aDate;
- (BOOL) kc_isThisYear;
- (BOOL) kc_isNextYear;
- (BOOL) kc_isLastYear;
- (BOOL) kc_isEarlierThanDate: (NSDate *) aDate;
- (BOOL) kc_isLaterThanDate: (NSDate *) aDate;

# pragma mark Date roles
- (BOOL) kc_isTypicallyWorkday;
- (BOOL) kc_isTypicallyWeekend;

# pragma mark Adjusting dates
- (NSDate *) kc_dateByAddingDays: (NSInteger) dDays;
- (NSDate *) kc_dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) kc_dateByAddingHours: (NSInteger) dHours;
- (NSDate *) kc_dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) kc_dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) kc_dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) kc_dateAtStartOfDay; //day of start date

# pragma mark Retrieving intervals
- (NSInteger) kc_secondsAfterDate: (NSDate *) aDate;
- (NSInteger) kc_secondsBeforeDate: (NSDate *) aDate;
- (NSInteger) kc_secondsAbsDate: (NSDate *) aDate;
- (NSInteger) kc_minutesAfterDate: (NSDate *) aDate;
- (NSInteger) kc_minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) kc_minutesAbsDate: (NSDate *) aDate;
- (NSInteger) kc_hoursAfterDate: (NSDate *) aDate;
- (NSInteger) kc_hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) kc_hoursAbsDate: (NSDate *) aDate;
- (NSInteger) kc_daysAfterDate: (NSDate *) aDate;
- (NSInteger) kc_daysBeforeDate: (NSDate *) aDate;
- (NSInteger) kc_daysAbsDate: (NSDate *) aDate;

# pragma mark Decomposing dates
@property (readonly) NSInteger kc_nearestHour;
@property (readonly) NSInteger kc_hour;
@property (readonly) NSInteger kc_minute;
@property (readonly) NSInteger kc_seconds;
@property (readonly) NSInteger kc_day;
@property (readonly) NSInteger kc_month;
@property (readonly) NSInteger kc_week; //week index in a year
@property (readonly) NSInteger kc_weekday; //week day, e.g. sun is 1
@property (readonly) NSInteger kc_nthWeekday; // e.g. weekday index in this month, index start from 1
@property (readonly) NSInteger kc_year;

@end
