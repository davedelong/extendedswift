//
//  GregorianDate.m
//  
//
//  Created by Dave DeLong on 5/29/23.
//

#import "GregorianDate.h"

#define IsLeapYear(_y) (((_y) % 400 == 0) || ((_y) % 4 == 0 && ((_y) % 100 != 0)))
#define IsInRange(_n, _l, _h) (_n >= _l && _n <= _h)

int8_t _Gregorian_LastDayOfMonthForYear(int8_t month, int16_t year) {
    if (month < 1 || month > 12) { return 0; }
    int8_t febDays = IsLeapYear(year) ? 29 : 28;
    int8_t days[13] = {0, 31, febDays, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    return days[month];
}

bool GregorianDateIsValid(GregorianDate date) {
    if (IsInRange(date.month, 1, 12) == false) { return false; }
    int8_t lastDay = _Gregorian_LastDayOfMonthForYear(date.month, date.year);
    if (IsInRange(date.day, 1, lastDay) == false) { return false; }
    
    if (date.hour < 0 || date.hour > 23) { return false; }
    if (date.minute < 0 || date.minute > 59) { return false; }
    if (date.second < 0 || date.second > 59) { return false; }
    return true;
}

time_t GregorianDateTimestamp(GregorianDate date) {
    if (GregorianDateIsValid(date) == false) { return INT_MIN; }
    time_t timestamp = 0;
    
    GregorianDate copy = date;
    GregorianDate(*adjustDate)(GregorianDate) = GregorianDateDecrementDay;
    time_t dayDelta = 86400;
    
    if (copy.year < 1970) {
        adjustDate = GregorianDateIncrementDay;
        dayDelta = -86400;
    }
    
    while((copy.year == 1970 && copy.month == 1 && copy.day == 1) == false) {
        copy = adjustDate(copy);
        timestamp += dayDelta;
    }
    
    timestamp += copy.hour * 3600;
    timestamp += copy.minute * 60;
    timestamp += copy.second;
    
    timestamp -= copy.tzoffset;
    
    return timestamp;
}

bool GregorianDateIsEqual(GregorianDate left, GregorianDate right) {
    if (GregorianDateIsValid(left) == false) { return false; }
    if (GregorianDateIsValid(right) == false) { return false; }
    
    return GregorianDateTimestamp(left) == GregorianDateTimestamp(right);
}

bool GregorianDateIsLeapYear(GregorianDate date) {
    return IsLeapYear(date.year);
}

GregorianDate GregorianDateIncrementDay(GregorianDate date) {
    if (GregorianDateIsValid(date) == false) { return; }
    GregorianDate copy = date;
    int8_t lastDayOfMonth = _Gregorian_LastDayOfMonthForYear(copy.month, copy.year);
    
    copy.day += 1;
    if (copy.day > lastDayOfMonth) {
        copy.day = 1;
        copy.month += 1;
        
        if (copy.month > 12) {
            copy.month = 1;
            copy.year += 1;
        }
    }
    return copy;
}

GregorianDate GregorianDateDecrementDay(GregorianDate date) {
    if (GregorianDateIsValid(date) == false) { return; }
    GregorianDate copy = date;
    copy.day -= 1;
    
    if (copy.day < 1) {
        copy.month -= 1;
        
        if (copy.month < 1) {
            copy.month = 12;
            copy.year -= 1;
        }
        
        copy.day = _Gregorian_LastDayOfMonthForYear(copy.month, copy.year);
    }
    return copy;
}

GregorianDate GregorianDateParseTimestamp(time_t timestamp, int16_t tzoffset) {
    GregorianDate date;
    date.year = 1970;
    date.month = 1;
    date.day = 1;
    date.hour = 0;
    date.minute = 0;
    date.second = 0;
    date.tzoffset = tzoffset;
    
    // normally this is bad, but i know what i'm doing
    timestamp += tzoffset;
    
    // there are far more "clever" ways of doing this, such as
    // https://github.com/llvm/llvm-project/blob/51eeea67c67cb3e622730ee1fa8c9b939268429b/libcxx/include/__chrono/year_month_day.h#L75
    
    // but this approach makes sense to me
    if (timestamp > 0) {
        // moving forwards from 1970
        while (timestamp >= 86400) {
            date = GregorianDateIncrementDay(date);
            timestamp -= 86400;
        }
    } else {
        while (timestamp < 0) {
            date = GregorianDateDecrementDay(date);
            timestamp += 86400;
        }
    }
    
    // now we get to the time component
    date.hour = timestamp / 3600;
    timestamp = timestamp % 3600;
    date.minute = timestamp / 60;
    date.second = timestamp % 60;
    
    return date;
}
