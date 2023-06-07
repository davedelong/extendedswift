//
//  GregorianDate+Format.h
//  
//
//  Created by Dave DeLong on 6/3/23.
//

#import <Foundation/Foundation.h>
#import "GregorianDate.h"

NS_ASSUME_NONNULL_BEGIN

// format a date into a string, using TR35 syntax
const char * _Nullable GregorianDateFormat(GregorianDate date, const char *format);
size_t GregorianDateFormatBuffer(GregorianDate date, const char *format, char *_Nullable buffer);


NS_ASSUME_NONNULL_END
