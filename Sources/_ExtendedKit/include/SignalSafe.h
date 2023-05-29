//
//  SignalSafe.h
//  
//
//  Created by Dave DeLong on 5/28/23.
//

#import <Foundation/Foundation.h>
#import "GregorianDate.h"

NS_ASSUME_NONNULL_BEGIN

void SafeFormatUInt(char *buffer, int d, int length);
void SafeFormatHex(char *buffer, int d, int length);

void SafeFormatUUID(__darwin_uuid_string_t _Nonnull buffer, uuid_t _Nonnull uuid);

void SafeFormatDate(char buffer[_Nonnull 20], GregorianDate);
void SafeFormatDateWithTimezone(char buffer[_Nonnull 26], GregorianDate);

void SafeFormatTimestamp(char buffer[_Nonnull 20], time_t timestamp);
void SafeFormatTimestampWithTimezone(char buffer[_Nonnull 26], time_t timestamp, int16_t tzoffset);

NS_ASSUME_NONNULL_END
