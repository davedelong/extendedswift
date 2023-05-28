//
//  SignalSafe.h
//  
//
//  Created by Dave DeLong on 5/28/23.
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

void SafeFormatUInt(char *buffer, int d, int length);
void SafeFormatHex(char *buffer, int d, int length);

void SafeFormatUUID(__darwin_uuid_string_t _Nonnull buffer, uuid_t _Nonnull uuid);

GregorianDate SafeTimestampParse(time_t timestamp, int16_t tzoffset);

void SafeFormatDate(char buffer[_Nonnull 20], GregorianDate);
void SafeFormatDateWithTimezone(char buffer[_Nonnull 26], GregorianDate);

void SafeFormatTimestamp(char buffer[_Nonnull 20], time_t timestamp);
void SafeFormatTimestampWithTimezone(char buffer[_Nonnull 26], time_t timestamp, int16_t tzoffset);

NS_ASSUME_NONNULL_END
