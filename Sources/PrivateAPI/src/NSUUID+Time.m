//
//  NSUUID+Time.m
//  
//
//  Created by Dave DeLong on 7/13/23.
//

#import "NSUUID+Time.h"
#import <uuid/uuid.h>
#import "SignalSafe.h"

@implementation NSUUID (ExtendedObjC)

+ (instancetype)extended_timedUUID {
    uuid_t u = {0};
    uuid_generate(u);
    
    uuid_string_t s = {0};
    SafeFormatUUID(s, u);
    
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *c = [cal componentsInTimeZone:[NSTimeZone defaultTimeZone] fromDate:[NSDate date]];
    
    char *yearStart = s + 0;
    char *monthStart = s + 4;
    char *dayStart = s + 6;
    SafeFormatUInt(yearStart, (int)c.year, 4);
    SafeFormatUInt(monthStart, (int)c.month, 2);
    SafeFormatUInt(dayStart, (int)c.day, 2);
    
    char *hourStart = s + 9;
    char *minStart = s + 11;
    SafeFormatUInt(hourStart, (int)c.hour, 2);
    SafeFormatUInt(minStart, (int)c.minute, 2);
    
    char *secStart = s + 14;
    char *subStart = s + 16;
    SafeFormatUInt(secStart, (int)c.second, 2);
    
    NSInteger subSecond = c.nanosecond * 100 / NSEC_PER_SEC;
    SafeFormatUInt(subStart, (int)subSecond, 2);
    
    return [[NSUUID alloc] initWithUUIDString:@(s)];
}

@end
