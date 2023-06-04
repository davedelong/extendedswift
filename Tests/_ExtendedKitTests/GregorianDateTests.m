//
//  GregorianDateTests.m
//  
//
//  Created by Dave DeLong on 6/3/23.
//

#import <XCTest/XCTest.h>
#import "GregorianDate.h"
#import "GregorianDate+Format.h"

#define XCTAssertEqualDate(_date, _y, _m, _d, _h, _mi, _s, _tz) ({ \
    XCTAssertEqual((_date).year, _y); \
    XCTAssertEqual((_date).month, _m); \
    XCTAssertEqual((_date).day, _d); \
    XCTAssertEqual((_date).hour, _h); \
    XCTAssertEqual((_date).minute, _mi); \
    XCTAssertEqual((_date).second, _s); \
    XCTAssertEqual((_date).tzoffset, _tz); \
})

@interface GregorianDateTests : XCTestCase

@end

@implementation GregorianDateTests

- (void)testParsing {
    GregorianDate d1 = GregorianDateParseTimestamp(0, 0);
    XCTAssertEqualDate(d1, 1970, 1, 1, 0, 0, 0, 0);
    
    time_t t1 = GregorianDateTimestamp(d1);
    XCTAssertEqual(t1, 0);
    
    GregorianDate d2 = GregorianDateParseTimestamp(-728271028, 0);
    XCTAssertEqualDate(d2, 1946, 12, 3, 22, 29, 32, 0);
    
    GregorianDate d3 = GregorianDateParseTimestamp(1584975600, -21600);
    XCTAssertEqualDate(d3, 2020, 03, 23, 9, 00, 00, -21600);
}

- (void)testFormatSizing {
    GregorianDate d1 = GregorianDateParseTimestamp(0, 0);
    
    // no format characters:
    size_t s1 = GregorianDateFormatBuffer(d1, "abc", NULL);
    XCTAssertEqual(s1, 3);
    
    // a single format character:
    size_t s2 = GregorianDateFormatBuffer(d1, "y", NULL);
    XCTAssertEqual(s2, 4); // should use the "natural" length of the unit
    
    // a fixed-length format sequence
    size_t s3 = GregorianDateFormatBuffer(d1, "yyyy", NULL);
    XCTAssertEqual(s3, 4);
    
    // multiple format sequences
    size_t s4 = GregorianDateFormatBuffer(d1, "ym", NULL);
    XCTAssertEqual(s4, 5); // year = 4, month = 1
    
    // multiple format sequences with non-format characters
    size_t s5 = GregorianDateFormatBuffer(d1, "y-m", NULL);
    XCTAssertEqual(s5, 6); // year = 4, month = 1
    
    // test simple escaping
    size_t s6 = GregorianDateFormatBuffer(d1, "'ab'", NULL);
    XCTAssertEqual(s6, 2);
    
    // test escaping format sequences
    size_t s7 = GregorianDateFormatBuffer(d1, "'y'", NULL);
    XCTAssertEqual(s7, 1);
    
    // test escaped single quote
    size_t s8 = GregorianDateFormatBuffer(d1, "''''", NULL);
    XCTAssertEqual(s8, 1);
    
    // test invalid escape sequence
    size_t s9 = GregorianDateFormatBuffer(d1, "yyyy-MM-dd'T", NULL);
    XCTAssertEqual(s9, 0);
    
    size_t s10 = GregorianDateFormatBuffer(d1, "yyyyMMdd'T'HHmmssZ", NULL);
    XCTAssertEqual(s10, 20);
}

@end
