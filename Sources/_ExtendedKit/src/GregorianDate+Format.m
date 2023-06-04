//
//  GregorianDate+Format.m
//  
//
//  Created by Dave DeLong on 6/3/23.
//

#import "GregorianDate+Format.h"
#import "SignalSafe.h"

#define SINGLE_QUOTE '\''
#define DIGIT_COUNT(_d) ((size_t)floor(log10((double)(_d)))+1)
#define UNIT_YEAR 'y'
#define UNIT_MONTH 'M'
#define UNIT_DAY 'd'
#define UNIT_HOUR 'H'
#define UNIT_MINUTE 'm'
#define UNIT_SECOND 's'
#define UNIT_TIMEZONE 'Z'

typedef struct _GDFormatSegment {
    char character;
    size_t formatCount;
} _GDFormatSegment;

typedef size_t(*_FormatFunction)(GregorianDate date, size_t formatCount, char *buffer);

typedef struct _GDFormatter {
    char character;
    size_t formatCount;
    _FormatFunction formatter;
} _GDFormatter;

bool _IsFormatChar(char c) {
    switch (c) {
        case 'y': return true;
        case 'M': return true;
        case 'd': return true;
        case 'H': return true;
        case 'm': return true;
        case 's': return true;
        case 'Z': return true;
        default: return false;
    }
}

int16_t _ValueForFormatChar(GregorianDate d, char c) {
    switch (c) {
        case 'y': return d.year;
        case 'M': return d.month;
        case 'd': return d.day;
        case 'H': return d.hour;
        case 'm': return d.minute;
        case 's': return d.second;
        case 'Z': return d.tzoffset;
        default: return 0;
    }
}

/// Destructure a format string into constituent segments of literals and format sequences.
///
/// If more segments are found than can fit in the buffer, then this function returns 0.
/// - Parameters:
///   - format: The format string to destructure
///   - segments: The buffer in which to list out the format sequences
///   - maxSegments: The maximum number of segments that can fit in the buffer
/// - Returns: The number of format segments in the format string, or 0 if the segments cannot fit in the provided buffer.
size_t _GDFormatParse(const char *format, _GDFormatSegment *segments, size_t maxSegments) {
    if (maxSegments == 0) { return 0; }
    
    size_t segmentCount = 0;
    
    size_t formatLength = strlen(format);
    if (formatLength == 0) { return 0; }
    
    char previousChar = 0;
    
    bool isEscaped = false;
    
    // POLICY: when starting a new loop, the segment count *ALWAYS* points to the next segment
    for (size_t f = 0; f < formatLength; f++) {
        
        // check to see if we have space to allow for more segments
        if (segmentCount == maxSegments) {
            // we do not; return 0 to indicate there was not enough space.
            return 0;
        }
        
        char currentChar = format[f];
        
        if (currentChar == SINGLE_QUOTE) {
            if (isEscaped == false && previousChar == SINGLE_QUOTE) {
                // double-escaped single-quote
                
                isEscaped = true;
                segments[segmentCount].formatCount = 0;
                segments[segmentCount].character = SINGLE_QUOTE;
                segmentCount += 1;
            } else {
                isEscaped = !isEscaped;
            }
        } else if (isEscaped) {
            segments[segmentCount].formatCount = 0;
            segments[segmentCount].character = currentChar;
            segmentCount += 1;
        } else if (_IsFormatChar(currentChar)) {
            // this might be the appendable to the previous segment
            if (segmentCount > 0 && segments[segmentCount-1].formatCount > 0 && segments[segmentCount-1].character == currentChar) {
                // append to the previous segment
                // do not increment the segment count
                segments[segmentCount-1].formatCount += 1;
            } else {
                // new segment
                segments[segmentCount].formatCount = 1;
                segments[segmentCount].character = currentChar;
                segmentCount += 1;
            }
        } else {
            // some fallback literal
            segments[segmentCount].formatCount = 0;
            segments[segmentCount].character = currentChar;
            segmentCount += 1;
        }
        
        previousChar = currentChar;
    }
    
    // if we still think things are escaped, then we have imbalanced quotes and an invalid format string
    if (isEscaped) { return 0; }
    
    return segmentCount;
}

size_t _GDWriteSegmentToBuffer(GregorianDate date, _GDFormatSegment segment, char *buffer) {
    if (segment.formatCount == 0) {
        if (buffer != NULL) {
            *buffer = segment.character;
        }
        return 1;
    } else {
        if (segment.character == UNIT_TIMEZONE) {
            int16_t value = _ValueForFormatChar(date, segment.character);
            
            return 5;
        } else {
            int16_t value = _ValueForFormatChar(date, segment.character);
            size_t naturalLength = DIGIT_COUNT(value);
            size_t digitsToWrite = naturalLength;
            
            if (segment.formatCount > 1) {
                digitsToWrite = segment.formatCount;
            }
            if (buffer != NULL) {
                if (digitsToWrite != naturalLength) {
                    // truncate the value to the number of digits required
                    size_t mod = pow(10, digitsToWrite + 1);
                    value = value % mod;
                }
                SafeFormatUInt(buffer, value, digitsToWrite);
            }
            
            return digitsToWrite;
        }
    }
}

size_t _GDFormatBuffer(GregorianDate date, const char *format, char *buffer, size_t maxSegmentCount) {
    _GDFormatSegment segments[maxSegmentCount];
    bzero(segments, maxSegmentCount);
    
    size_t segmentCount = _GDFormatParse(format, segments, maxSegmentCount);
    if (segmentCount == 0) {
        // there isn't enough space
        return 0;
    }
    
    printf("==============================\n");
    printf("format: %s\n", format);
    printf("segments: (%zu)\n", segmentCount);
    
    char *currentBufferPosition = buffer;
    size_t totalBytesWritten = 0;
    for (size_t s = 0; s < segmentCount; s++) {
        size_t bytesWritten = _GDWriteSegmentToBuffer(date, segments[s], currentBufferPosition);
        if (currentBufferPosition != NULL) { currentBufferPosition += bytesWritten; }
        totalBytesWritten += bytesWritten;
        
        if (segments[s].formatCount > 0) {
            printf("- %c x %zu (FORMAT) -> %zu\n", segments[s].character, segments[s].formatCount, bytesWritten);
        } else {
            printf("- %c (LITERAL) -> %zu\n", segments[s].character, bytesWritten);
        }
    }
    printf("total bytes: %zu\n", totalBytesWritten);
    
    return totalBytesWritten;
}

// MARK: - API

size_t GregorianDateFormatBuffer(GregorianDate date, const char *format, char *buffer) {
    size_t formatLength = strlen(format);
    size_t segmentLengthMultiplier = 0;
    
    while (segmentLengthMultiplier < 10) {
        segmentLengthMultiplier += 1;
        size_t maxSegmentCount = formatLength * segmentLengthMultiplier;
        size_t bufferSize = _GDFormatBuffer(date, format, buffer, maxSegmentCount);
        if (bufferSize > 0) { return bufferSize; }
    }
    
    // the format was too complex to properly parse
    // likely this is because there are lots of '''' segments
    return 0;
}

const char *GregorianDateFormat(GregorianDate date, const char *format) {
    size_t requiredLength = GregorianDateFormatBuffer(date, format, NULL);
    char *buffer = calloc(requiredLength + 1, sizeof(char));
    
    GregorianDateFormatBuffer(date, format, buffer);
    return buffer;
}
