//
//  GregorianDate+Format.m
//  
//
//  Created by Dave DeLong on 6/3/23.
//

#import "GregorianDate+Format.h"
#import "GregorianDate+Formatters.h"
#import "SignalSafe.h"

#define SINGLE_QUOTE '\''
#define DIGIT_COUNT(_d) ((size_t)floor(log10((double)(_d)))+1)

typedef struct _GDFormatSegment {
    char character;
    size_t count;
    _GDFormatFunction formatter;
} _GDFormatSegment;

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
            if (isEscaped && previousChar == SINGLE_QUOTE) {
                // double-escaped single-quote
                segments[segmentCount].count = 1;
                segments[segmentCount].character = SINGLE_QUOTE;
                segments[segmentCount].formatter = NULL;
                segmentCount += 1;
            }
            isEscaped = !isEscaped;
        } else if (isEscaped) {
            segments[segmentCount].count = 1;
            segments[segmentCount].character = currentChar;
            segments[segmentCount].formatter = NULL;
            segmentCount += 1;
        } else {
            if (_GDIsFormatCharacter(currentChar)) {
                // it's a format character
                if (segmentCount > 0 && segments[segmentCount-1].formatter != NULL && segments[segmentCount-1].character == currentChar) {
                    // it's the same as the last format character
                    segments[segmentCount-1].count += 1;
                    segments[segmentCount-1].formatter = _GDFormatterLookup(currentChar, segments[segmentCount-1].count);
                } else {
                    // it's a new format character
                    segments[segmentCount].count = 1;
                    segments[segmentCount].character = currentChar;
                    segments[segmentCount].formatter = _GDFormatterLookup(currentChar, 1);
                    segmentCount += 1;
                }
            } else {
                // it's a literal character
                if (segmentCount > 0 && segments[segmentCount-1].formatter == NULL && segments[segmentCount-1].character == currentChar) {
                    // it's the same as the last literal character
                    segments[segmentCount-1].count += 1;
                } else {
                    // it's a new literal segment
                    segments[segmentCount].count = 1;
                    segments[segmentCount].character = currentChar;
                    segments[segmentCount].formatter = NULL;
                    segmentCount += 1;
                }
                
            }
        }
        
        previousChar = currentChar;
    }
    
    // if we still think things are escaped, then we have imbalanced quotes and an invalid format string
    if (isEscaped) { return 0; }
    
    return segmentCount;
}

size_t _GDFormatBuffer(GregorianDate date, const char *format, char *buffer, size_t maxSegmentCount) {
    _GDFormatSegment segments[maxSegmentCount];
    bzero(segments, maxSegmentCount);
    
    size_t segmentCount = _GDFormatParse(format, segments, maxSegmentCount);
    if (segmentCount == 0) {
        // there isn't enough space
        return 0;
    }
    
    char *currentBufferPosition = buffer;
    size_t totalBytesWritten = 0;
    for (size_t s = 0; s < segmentCount; s++) {
        _GDFormatSegment segment = segments[s];
        
        size_t bytesWritten = 0;
        if (segment.formatter != NULL && segment.count > 0) {
            bytesWritten = segment.formatter(date, segment.count, currentBufferPosition);
        } else {
            for (size_t i = 0; i < segment.count; i++) {
                if (currentBufferPosition != NULL) {
                    *currentBufferPosition = segment.character;
                }
                bytesWritten += 1;
            }
        }
        if (currentBufferPosition != NULL) { currentBufferPosition += bytesWritten; }
        totalBytesWritten += bytesWritten;
    }
    
    return totalBytesWritten;
}

// MARK: - API

size_t GregorianDateFormatBuffer(GregorianDate date, const char *format, char *buffer) {
    if (GregorianDateIsValid(date) == false) { return 0; }
    
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

const char * _Nullable GregorianDateFormat(GregorianDate date, const char *format) {
    if (GregorianDateIsValid(date) == false) { return NULL; }
    
    size_t requiredLength = GregorianDateFormatBuffer(date, format, NULL);
    char *buffer = calloc(requiredLength + 1, sizeof(char));
    
    GregorianDateFormatBuffer(date, format, buffer);
    return buffer;
}
