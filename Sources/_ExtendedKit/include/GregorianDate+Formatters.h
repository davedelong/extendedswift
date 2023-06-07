//
//  GregorianDate+Formatters.h
//  
//
//  Created by Dave DeLong on 6/4/23.
//

#import <Foundation/Foundation.h>
#import "GregorianDate.h"

NS_ASSUME_NONNULL_BEGIN

typedef size_t(*_GDFormatFunction)(GregorianDate date, size_t formatCount, char *buffer);

bool _GDIsFormatCharacter(char unit);

_Nullable _GDFormatFunction _GDFormatterLookup(char unit, size_t formatCount);

NS_ASSUME_NONNULL_END
