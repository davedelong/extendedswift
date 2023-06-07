//
//  GregorianDateTests.m
//  
//
//  Created by Dave DeLong on 6/3/23.
//

#import <XCTest/XCTest.h>
#import "GregorianDate.h"
#import "GregorianDate+Format.h"
#import <objc/runtime.h>

#define XCTAssertEqualDate(_date, _y, _m, _d, _h, _mi, _s, _tz) ({ \
    XCTAssertEqual((_date).year, _y); \
    XCTAssertEqual((_date).month, _m); \
    XCTAssertEqual((_date).day, _d); \
    XCTAssertEqual((_date).hour, _h); \
    XCTAssertEqual((_date).minute, _mi); \
    XCTAssertEqual((_date).second, _s); \
    XCTAssertEqual((_date).tzoffset, _tz); \
})

typedef struct _FormatTest {
    const char *name;
    const char *format;
    size_t expectedLength;
    
    NSInteger line;
} _FormatTest;

_FormatTest formatTests[] = {
    {"no format characters", "123", 3, __LINE__},
    {"single format character", "y", 4, __LINE__},
    {"fixed-length format sequence", "yyyy", 4, __LINE__},
    {"multiple format sequences", "ym", 5, __LINE__},
    {"multiple format sequences with literal characters", "y-m", 6, __LINE__},
    {"simple escaping", "'ab'", 2, __LINE__},
    {"escaping format sequences", "'y'", 1, __LINE__},
    {"escaped single quote", "''''", 2, __LINE__},
    {"invalid escape sequence", "yyyy-MM-dd'T", 0, __LINE__},
    {"full-length format", "yyyyMMdd'T'HHmmssZ", 22, __LINE__},
    {"format preceding literal", "yyyy'a'", 5, __LINE__},
    {"format following literal", "'a'yyyy", 5, __LINE__},
};
size_t formatTestCount = sizeof(formatTests)/sizeof(_FormatTest);

@interface GregorianDateTests : XCTestCase

@end

@implementation GregorianDateTests

+ (NSInvocation *)testInvocationWithName:(NSString *)name block:(void(^)(id))testBlock {
    NSString *methodName = [NSString stringWithFormat:@"formats: %@", name];
    SEL methodSelector = sel_getUid(methodName.UTF8String);
    IMP imp = imp_implementationWithBlock(testBlock);
    class_addMethod(self, methodSelector, imp, "v@:");
    
    NSMethodSignature *sig = [self instanceMethodSignatureForSelector:methodSelector];
    NSInvocation *i = [NSInvocation invocationWithMethodSignature:sig];
    i.selector = methodSelector;
    return i;
}

+ (NSArray<NSInvocation *> *)testInvocations {
    NSMutableArray<NSInvocation *> *invocations = [[super testInvocations] mutableCopy];
    
    for (size_t i = 0; i < formatTestCount; i++) {
        _FormatTest f = formatTests[i];
        [invocations addObject:[self testInvocationWithName:@(f.name) block:^(id _self){
            GregorianDate d1 = GregorianDateParseTimestamp(0, 0);
            size_t actual = GregorianDateFormatBuffer(d1, f.format, NULL);
            if (actual != f.expectedLength) {
                NSString *msg = [NSString stringWithFormat:@"Formatting failure for '%s': Expected %zu but got %zu", f.name, f.expectedLength, actual];
                XCTSourceCodeLocation *loc = [[XCTSourceCodeLocation alloc] initWithFilePath:@__FILE__ lineNumber:f.line];
                XCTSourceCodeContext *ctx = [[XCTSourceCodeContext alloc] initWithLocation:loc];
                XCTIssue *issue = [[XCTIssue alloc] initWithType:XCTIssueTypeAssertionFailure
                                              compactDescription:[NSString stringWithFormat:@"expected %zu ≠ actual %zu", f.expectedLength, actual]
                                             detailedDescription:msg
                                               sourceCodeContext:ctx
                                                 associatedError:nil
                                                     attachments:@[]];
                [_self recordIssue:issue];
            }
        }]];
    }
    
    return invocations;
}

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


@end
