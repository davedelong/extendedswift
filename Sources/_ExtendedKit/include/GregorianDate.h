//
//  GregorianDate.h
//  
//
//  Created by Dave DeLong on 5/29/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct GregorianDate {
    int16_t year;
    int8_t month;
    int8_t day;
    
    int8_t hour;
    int8_t minute;
    int8_t second;
    
    int16_t tzoffset;
} GregorianDate;

GregorianDate GregorianDateParseTimestamp(time_t timestamp, int16_t tzoffset);
time_t GregorianDateTimestamp(GregorianDate date);

bool GregorianDateIsEqual(GregorianDate left, GregorianDate right);

bool GregorianDateIsValid(GregorianDate date);
bool GregorianDateIsLeapYear(GregorianDate date);

GregorianDate GregorianDateIncrementDay(GregorianDate date);
GregorianDate GregorianDateDecrementDay(GregorianDate date);

NS_ASSUME_NONNULL_END
