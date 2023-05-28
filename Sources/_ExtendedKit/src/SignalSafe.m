//
//  SignalSafe.m
//  
//
//  Created by Dave DeLong on 5/28/23.
//

#import "SignalSafe.h"

void SafeFormatUInt(char *buffer, int d, int length) {
    int remaining = d;
    if (remaining < 0) { return; }
    
    if (d == 0) {
        for (int i = 0; i < length; i++) {
            *buffer = '0';
            buffer++;
        }
    } else {
        double magnitude = floor(log10((double)remaining));
        
        if (magnitude > length) { return; }
        
        int leadingZeroes = length - magnitude - 1;
        for (int i = 0; i < leadingZeroes; i++) {
            *buffer = '0';
            buffer++;
        }
        
        while (magnitude >= 0) {
            int power = (int)pow(10, magnitude);
            int8_t digit = remaining / power;
            *buffer = digit + '0';
            buffer++;
            remaining %= power;
            magnitude -= 1;
        }
    }
}

void SafeFormatHex(char *buffer, int d, int length) {
    if (d == 0) {
        for (int i = 0; i < length; i++) {
            *buffer = '0';
            buffer++;
        }
    } else {
        int remaining = d;
        double hexMagnitude = floor(log(remaining)/log(16));
        if (hexMagnitude > length) { return; }
        int leadingZeroes = length - hexMagnitude - 1;
        for (int i = 0; i < leadingZeroes; i++) {
            *buffer = '0';
            buffer++;
        }
        while (hexMagnitude >= 0) {
            int power = (int)pow(16, hexMagnitude);
            int8_t digit = remaining / power;
            
            if (digit < 10) {
                *buffer = digit + '0';
            } else {
                *buffer = (digit - 10) + 'A';
            }
            buffer++;
            remaining %= power;
            hexMagnitude -= 1;
        }
    }
}

void SafeFormatUUID(__darwin_uuid_string_t buffer, uuid_t uuid) {
    SafeFormatHex(buffer, uuid[0], 2);
    SafeFormatHex(buffer+2, uuid[1], 2);
    SafeFormatHex(buffer+4, uuid[2], 2);
    SafeFormatHex(buffer+6, uuid[3], 2);
    buffer[8] = '-';
    SafeFormatHex(buffer+9, uuid[4], 2);
    SafeFormatHex(buffer+11, uuid[5], 2);
    buffer[13] = '-';
    SafeFormatHex(buffer+14, uuid[6], 2);
    SafeFormatHex(buffer+16, uuid[7], 2);
    buffer[18] = '-';
    SafeFormatHex(buffer+19, uuid[8], 2);
    SafeFormatHex(buffer+21, uuid[9], 2);
    buffer[23] = '-';
    SafeFormatHex(buffer+24, uuid[10], 2);
    SafeFormatHex(buffer+26, uuid[11], 2);
    SafeFormatHex(buffer+28, uuid[12], 2);
    SafeFormatHex(buffer+30, uuid[13], 2);
    SafeFormatHex(buffer+32, uuid[14], 2);
    SafeFormatHex(buffer+34, uuid[15], 2);
}

#define IsLeapYear(_y) (((_y) % 400 == 0) || ((_y) % 4 == 0 && ((_y) % 100 != 0)))

GregorianDate SafeTimestampParse(time_t timestamp, int16_t tzoffset) {
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
            date.day += 1;
            
            if (date.day > 31 && date.month == 1) {
                date.day = 1; date.month += 1;
            } else if (date.day > 29 && date.month == 2) {
                // leap feb
                date.day = 1; date.month += 1;
            } else if (date.day > 28 && date.month == 2 && IsLeapYear(date.year) == false) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 3) {
                date.day = 1; date.month += 1;
            } else if (date.day > 30 && date.month == 4) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 5) {
                date.day = 1; date.month += 1;
            } else if (date.day > 30 && date.month == 6) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 7) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 8) {
                date.day = 1; date.month += 1;
            } else if (date.day > 30 && date.month == 9) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 10) {
                date.day = 1; date.month += 1;
            } else if (date.day > 30 && date.month == 11) {
                date.day = 1; date.month += 1;
            } else if (date.day > 31 && date.month == 12) {
                date.day = 1; date.month = 1; date.year += 1;
            }
            timestamp -= 86400;
        }
    } else {
        while (timestamp < 0) {
            date.day -= 1;
            
            if (date.day <= 0 && date.month == 12) {
                date.day = 30; date.month -= 1;
            } else if (date.day <= 0 && date.month == 11) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 10) {
                date.day = 30; date.month -= 1;
            } else if (date.day <= 0 && date.month == 9) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 8) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 7) {
                date.day = 30; date.month -= 1;
            } else if (date.day <= 0 && date.month == 6) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 5) {
                date.day = 30; date.month -= 1;
            } else if (date.day <= 0 && date.month == 4) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 3) {
                date.day = (IsLeapYear(date.year)) ? 29 : 28; date.month -= 1;
            } else if (date.day <= 0 && date.month == 2) {
                date.day = 31; date.month -= 1;
            } else if (date.day <= 0 && date.month == 1) {
                date.day = 31; date.month = 12; date.year -= 1;
            }
            
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

void SafeFormatDate(char buffer[_Nonnull 20], GregorianDate date) {
    // yyyy-mm-dd HH:mm:ss
    SafeFormatUInt(buffer, date.year, 4);
    SafeFormatUInt(buffer+5, date.month, 2);
    SafeFormatUInt(buffer+8, date.day, 2);
    SafeFormatUInt(buffer+11, date.hour, 2);
    SafeFormatUInt(buffer+14, date.minute, 2);
    SafeFormatUInt(buffer+17, date.second, 2);
}

void SafeFormatDateWithTimezone(char buffer[_Nonnull 26], GregorianDate date) {
    buffer[20] = (date.tzoffset < 0) ? '-' : '+';
    int tz = abs(date.tzoffset);
    
    int tzhour = tz / 3600;
    int tzmin = tz % 3600;
    SafeFormatUInt(buffer+21, tzhour, 2);
    SafeFormatUInt(buffer+23, tzmin, 2);
}

void SafeFormatTimestamp(char buffer[_Nonnull 20], time_t timestamp) {
    GregorianDate date = SafeTimestampParse(timestamp, 0);
    SafeFormatDate(buffer, date);
}

void SafeFormatTimestampWithTimezone(char buffer[_Nonnull 26], time_t timestamp, int16_t tzoffset) {
    GregorianDate date = SafeTimestampParse(timestamp, tzoffset);
    SafeFormatDateWithTimezone(buffer, date);
}
