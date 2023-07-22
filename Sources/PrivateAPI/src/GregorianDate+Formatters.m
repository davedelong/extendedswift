//
//  GregorianDate+Formatters.m
//  
//
//  Created by Dave DeLong on 6/4/23.
//

#import "GregorianDate+Formatters.h"

#define GD_ANY -1
#define DIGIT_COUNT(_d) ((size_t)floor(log10((double)(_d)))+1)

/*
 Missing things:
 - day of the week
 - week of month
 - week of year
 - variant era
 */

typedef struct _GDFormatter {
    char character;
    size_t formatCount;
    _GDFormatFunction formatter;
} _GDFormatter;

typedef struct _GDTimezone {
    int64_t hour;
    int8_t minute;
    int8_t second;
} _GDTimezone;

_GDTimezone _GregorianDateTimezone(GregorianDate date);

size_t _GDFormatEra(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatEraWide(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatEraNarrow(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatYear(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatQuarterNumeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatQuarterNameShort(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatQuarterNameWide(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatMonthShort(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatMonthWide(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatMonthNarrow(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatMonthNumeric(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatDayNumeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatDayOfYearNumeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatDayJulian(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatHour23Numeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatHour12Numeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatHour24Numeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatHour11Numeric(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatPeriod(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatPeriodNarrow(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatMinuteNumeric(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatSecondNumeric(GregorianDate date, size_t formatCount, char *buffer);

size_t _GDFormatTimezoneLongGMT(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601ExtendedHMSZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHMS(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneLongGMT(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneShortGMT(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHMZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601ExtendedHMZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHMSZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601ExtendedHMSZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHZ(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHM(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601ExtendedHM(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicHMS(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601ExtendedHMS(GregorianDate date, size_t formatCount, char *buffer);
size_t _GDFormatTimezoneISO8601BasicH(GregorianDate date, size_t formatCount, char *buffer);

const _GDFormatter formatters[] = {
    {'G', 4, _GDFormatEraWide},
    {'G', 5, _GDFormatEraNarrow},
    {'G', GD_ANY, _GDFormatEra},
    
    {'y', GD_ANY, _GDFormatYear},
    
    {'Q', 3, _GDFormatQuarterNameShort},
    {'Q', 4, _GDFormatQuarterNameWide},
    {'Q', GD_ANY, _GDFormatQuarterNumeric},
    
    {'q', 3, _GDFormatQuarterNameShort},
    {'q', 4, _GDFormatQuarterNameWide},
    {'q', GD_ANY, _GDFormatQuarterNumeric},
    
    {'M', 3, _GDFormatMonthShort},
    {'M', 4, _GDFormatMonthWide},
    {'M', 5, _GDFormatMonthNarrow},
    {'M', GD_ANY, _GDFormatMonthNumeric},
    
    {'L', 3, _GDFormatMonthShort},
    {'L', 4, _GDFormatMonthWide},
    {'L', 5, _GDFormatMonthNarrow},
    {'L', GD_ANY, _GDFormatMonthNumeric},
    
    {'d', GD_ANY, _GDFormatDayNumeric},
    {'D', GD_ANY, _GDFormatDayOfYearNumeric},
    {'g', GD_ANY, _GDFormatDayJulian},
    
    {'h', GD_ANY, _GDFormatHour12Numeric},
    {'H', GD_ANY, _GDFormatHour23Numeric},
    {'k', GD_ANY, _GDFormatHour11Numeric},
    {'K', GD_ANY, _GDFormatHour24Numeric},
    
    {'a', 5, _GDFormatPeriodNarrow},
    {'a', GD_ANY, _GDFormatPeriod},
    
    {'m', GD_ANY, _GDFormatMinuteNumeric},
    {'s', GD_ANY, _GDFormatSecondNumeric},
    
    // TIMEZONES
    
    {'Z', 4, _GDFormatTimezoneLongGMT}, // same as 'OOOO'
    {'Z', 5, _GDFormatTimezoneISO8601ExtendedHMSZ}, // same as 'XXXXX'
    {'Z', GD_ANY, _GDFormatTimezoneISO8601BasicHMS}, // same as 'xxxx'
    
    {'O', 4, _GDFormatTimezoneLongGMT},
    {'O', GD_ANY, _GDFormatTimezoneShortGMT},
    
    {'X', 2, _GDFormatTimezoneISO8601BasicHMZ},
    {'X', 3, _GDFormatTimezoneISO8601ExtendedHMZ},
    {'X', 4, _GDFormatTimezoneISO8601BasicHMSZ},
    {'X', 5, _GDFormatTimezoneISO8601ExtendedHMSZ},
    {'X', GD_ANY, _GDFormatTimezoneISO8601BasicHZ},
    
    {'x', 2, _GDFormatTimezoneISO8601BasicHM},
    {'x', 3, _GDFormatTimezoneISO8601ExtendedHM},
    {'x', 4, _GDFormatTimezoneISO8601BasicHMS},
    {'x', 5, _GDFormatTimezoneISO8601ExtendedHMS},
    {'x', GD_ANY, _GDFormatTimezoneISO8601BasicH},
};

const size_t _GDFormatterCount = sizeof(formatters) / sizeof(_GDFormatter);

_Nullable _GDFormatFunction _GDFormatterLookup(char unit, size_t formatCount) {
    for (size_t f = 0; f < _GDFormatterCount; f++) {
        if (formatters[f].character != unit) { continue; }
        
        if (formatters[f].formatCount == GD_ANY) { return formatters[f].formatter; }
        if (formatters[f].formatCount == formatCount) { return formatters[f].formatter; }
    }
    return NULL;
}

bool _GDIsFormatCharacter(char unit) {
    return _GDFormatterLookup(unit, 1) != NULL;
}

// MARK: - Helpers

_GDTimezone _GregorianDateTimezone(GregorianDate date) {
    _GDTimezone tz = {0};
    
    int64_t offset = date.tzoffset;
    tz.hour = offset / 3600;
    
    offset = llabs(offset % 3600);
    
    tz.minute = offset / 60;
    tz.second = offset % 60;
    return tz;
}

size_t _GDWriteString(const char *string, char *buffer) {
    size_t charCount = strlen(string);
    if (buffer != NULL) { memcpy(buffer, string, charCount); }
    return charCount;
}

size_t _GDWriteInt(int64_t d, size_t maxLength, char *buffer) {
    int64_t remaining = d;
    size_t written = 0;
    
    if (remaining < 0) { return written; }
    
    
    if (d == 0) {
        if (buffer != NULL) {
            for (int i = 0; i < maxLength; i++) {
                *buffer = '0';
                buffer++;
            }
        }
        return maxLength;
    } else {
        double magnitude = floor(log10((double)remaining));
        
        if (magnitude > maxLength) { return; }
        
        int leadingZeroes = maxLength - magnitude - 1;
        for (int i = 0; i < leadingZeroes; i++) {
            if (buffer != NULL) {
                *buffer = '0';
                buffer++;
            }
            written += 1;
        }
        
        while (magnitude >= 0) {
            if (buffer != NULL) {
                int power = (int)pow(10, magnitude);
                int8_t digit = remaining / power;
                *buffer = digit + '0';
                buffer++;
                remaining %= power;
            }
            magnitude -= 1;
            written += 1;
        }
    }
    return written;
}

// MARK: - Formatter Implementations

// MARK: Era

size_t _GDFormatEra(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteString("AD", buffer);
}
size_t _GDFormatEraWide(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteString("Anno Domini", buffer);
}
size_t _GDFormatEraNarrow(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteString("A", buffer);
}

// MARK: Year

size_t _GDFormatYear(GregorianDate date, size_t formatCount, char *buffer) {
    size_t maxLength = (formatCount == 1) ? DIGIT_COUNT(date.year) : formatCount;
    return _GDWriteInt(date.year, maxLength, buffer);
}

// MARK: Quarter

size_t _GDFormatQuarterNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    int8_t quarter = GregorianDateQuarter(date);
    if (quarter >= 1 && quarter <= 4) {
        return _GDWriteInt(quarter, formatCount, buffer);
    }
    return 0;
}
size_t _GDFormatQuarterNameShort(GregorianDate date, size_t formatCount, char *buffer) {
    int8_t quarter = GregorianDateQuarter(date);
    if (quarter >= 1 && quarter <= 4) {
        size_t written = _GDWriteString("Q", buffer);
        written += _GDWriteInt(quarter, 1, buffer);
        return written;
    }
    return 0;
}
size_t _GDFormatQuarterNameWide(GregorianDate date, size_t formatCount, char *buffer) {
    int8_t quarter = GregorianDateQuarter(date);
    switch (quarter) {
        case 1: return _GDWriteString("1st quarter", buffer);
        case 2: return _GDWriteString("2nd quarter", buffer);
        case 3: return _GDWriteString("3rd quarter", buffer);
        case 4: return _GDWriteString("4th quarter", buffer);
        default: return 0;
    }
}

// MARK: Month

const char *shortMonthNames[] = { "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
const char *wideMonthNames[] = { "", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
const char *narrowMonthNames[] = { "", "J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D" };

size_t _GDFormatMonthShort(GregorianDate date, size_t formatCount, char *buffer) {
    if (date.month < 1 || date.month > 12) { return 0; }
    return _GDWriteString(shortMonthNames[date.month], buffer);
}
size_t _GDFormatMonthWide(GregorianDate date, size_t formatCount, char *buffer) {
    if (date.month < 1 || date.month > 12) { return 0; }
    return _GDWriteString(wideMonthNames[date.month], buffer);
}
size_t _GDFormatMonthNarrow(GregorianDate date, size_t formatCount, char *buffer) {
    if (date.month < 1 || date.month > 12) { return 0; }
    return _GDWriteString(narrowMonthNames[date.month], buffer);
}
size_t _GDFormatMonthNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    if (date.month < 1 || date.month > 12) { return 0; }
    return _GDWriteInt(date.month, formatCount, buffer);
}

// MARK: Day

size_t _GDFormatDayNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.day, formatCount, buffer);
}
size_t _GDFormatDayOfYearNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    int8_t doy = GregorianDateDayOfYear(date);
    return _GDWriteInt(doy, formatCount, buffer);
}
size_t _GDFormatDayJulian(GregorianDate date, size_t formatCount, char *buffer) {
    int64_t j = GregorianDateJulianDay(date);
    return _GDWriteInt(j, formatCount, buffer);
}

// MARK: Hour

size_t _GDFormatHour23Numeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.hour, formatCount, buffer);
}
size_t _GDFormatHour12Numeric(GregorianDate date, size_t formatCount, char *buffer) {
    int8_t hour = date.hour % 12;
    if (hour == 0) { hour = 12; }
    return _GDWriteInt(hour, formatCount, buffer);
}
size_t _GDFormatHour24Numeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.hour + 1, formatCount, buffer);
}
size_t _GDFormatHour11Numeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.hour % 12, formatCount, buffer);
}

// MARK: Period

size_t _GDFormatPeriod(GregorianDate date, size_t formatCount, char *buffer) {
    const char *p = (date.hour < 12) ? "am" : "pm";
    return _GDWriteString(p, buffer);
}
size_t _GDFormatPeriodNarrow(GregorianDate date, size_t formatCount, char *buffer) {
    const char *p = (date.hour < 12) ? "a" : "p";
    return _GDWriteString(p, buffer);
}

// MARK: Minute

size_t _GDFormatMinuteNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.minute, formatCount, buffer);
}

// MARK: Second

size_t _GDFormatSecondNumeric(GregorianDate date, size_t formatCount, char *buffer) {
    return _GDWriteInt(date.second, formatCount, buffer);
}

// MARK: TimeZone

size_t _GDFormatTimezoneLongGMT(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString("GMT", buffer);
    written += _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneShortGMT(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString("GMT", buffer);
    written += _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    if (tz.minute > 0) {
        written += _GDWriteString(":", buffer);
        written += _GDWriteInt(tz.minute, 2, buffer);
    }
    return written;
}
size_t _GDFormatTimezoneISO8601BasicHMZ(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    if (tz.hour == 0 && tz.minute == 0 && tz.second == 0) {
        return _GDWriteString("Z", buffer);
    }
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601ExtendedHMZ(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    if (tz.hour == 0 && tz.minute == 0 && tz.second == 0) {
        return _GDWriteString("Z", buffer);
    }
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601BasicHMSZ(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    if (tz.hour == 0 && tz.minute == 0 && tz.second == 0) {
        return _GDWriteString("Z", buffer);
    }
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    if (tz.second > 0) {
        written += _GDWriteInt(tz.second, 2, buffer);
    }
    return written;
}
size_t _GDFormatTimezoneISO8601ExtendedHMSZ(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    if (tz.hour == 0 && tz.minute == 0 && tz.second == 0) {
        return _GDWriteString("Z", buffer);
    }
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    if (tz.second > 0) {
        written += _GDWriteString(":", buffer);
        written += _GDWriteInt(tz.second, 2, buffer);
    }
    return written;
}
size_t _GDFormatTimezoneISO8601BasicHZ(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    if (tz.hour == 0 && tz.minute == 0 && tz.second == 0) {
        return _GDWriteString("Z", buffer);
    }
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    if (tz.second > 0) {
        written += _GDWriteInt(tz.minute, 2, buffer);
    }
    return written;
}
size_t _GDFormatTimezoneISO8601BasicHM(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601ExtendedHM(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601BasicHMS(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    written += _GDWriteInt(tz.second, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601ExtendedHMS(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.minute, 2, buffer);
    written += _GDWriteString(":", buffer);
    written += _GDWriteInt(tz.second, 2, buffer);
    return written;
}
size_t _GDFormatTimezoneISO8601BasicH(GregorianDate date, size_t formatCount, char *buffer) {
    _GDTimezone tz = _GregorianDateTimezone(date);
    size_t written = _GDWriteString(tz.hour < 0 ? "-" : "+", buffer);
    written += _GDWriteInt(llabs(tz.hour), 2, buffer);
    if (tz.second > 0) {
        written += _GDWriteInt(tz.minute, 2, buffer);
    }
    return written;
}
