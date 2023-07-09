//
//  SignalSafe.h
//  
//
//  Created by Dave DeLong on 5/28/23.
//

#import <Foundation/Foundation.h>
#import "GregorianDate.h"

NS_ASSUME_NONNULL_BEGIN

void SafeFormatUInt(char *buffer, int d, size_t length);
void SafeFormatHex(char *buffer, int d, size_t length);

void SafeFormatUUID(__darwin_uuid_string_t _Nonnull buffer, uuid_t _Nonnull uuid);

NS_ASSUME_NONNULL_END
