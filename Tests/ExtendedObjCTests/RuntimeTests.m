//
//  RuntimeTests.m
//  
//
//  Created by Dave DeLong on 7/20/23.
//

#import <XCTest/XCTest.h>
#import "Runtime.h"

@interface RuntimeTests : XCTestCase

@end

@implementation RuntimeTests

- (void)testTypeEncodingIteration {
    
    const char *t1 = "v@:";
    __block int count = 0;
    typeEncoding_enumerateTypes(t1, ^(const char * _Nonnull type, BOOL * _Nonnull keepGoing) {
        count += 1;
        if (count == 1) {
            XCTAssertTrue(strcmp(type, "v") == 0);
        } else if (count == 2) {
            XCTAssertTrue(strcmp(type, "@") == 0);
        } else if (count == 3) {
            XCTAssertTrue(strcmp(type, ":") == 0);
        } else {
            XCTFail();
        }
    });
    
    XCTAssertEqual(count, 3);
    
}

- (void)testInvalidTypeIteration {
    const char *t1 = "hello, world!";
    __block int count = 0;
    typeEncoding_enumerateTypes(t1, ^(const char * _Nonnull type, BOOL * _Nonnull keepGoing) {
        count += 1;
    });
    XCTAssertEqual(count, 0);
    
    count = 0;
    typeEncoding_enumerateTypes("void", ^(const char * _Nonnull type, BOOL * _Nonnull keepGoing) {
        count += 1;
    });
    XCTAssertEqual(count, 3);
    
    Class nsview = NSClassFromString(@"NSView");
    class_enumerateIvars(nsview, ^(Ivar  _Nonnull i, BOOL * _Nonnull keepGoing) {
        const char *typeEncoding = ivar_getTypeEncoding(i);
        const char *name = ivar_getName(i);
        
        printf("%s - %s\n", name, typeEncoding);
        typeEncoding_enumerateTypes(typeEncoding, ^(const char * _Nonnull type, BOOL * _Nonnull keepGoing) {
            printf("  %s\n", type);
        });
    });
    class_enumerateInstanceMethods(nsview, ^(Method  _Nonnull m, BOOL * _Nonnull keepGoing) {
        const char *typeEncoding = method_getTypeEncoding(m);
        const char *name = sel_getName(method_getName(m));
        
        printf("%s - %s\n", name, typeEncoding);
        typeEncoding_enumerateTypes(typeEncoding, ^(const char * _Nonnull type, BOOL * _Nonnull keepGoing) {
            printf("  %s\n", type);
        });
    });
}

@end
