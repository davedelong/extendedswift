//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/25/23.
//

import Foundation
import ExtendedSwift
import XCTest

class BuilderTests: XCTestCase {
    
    func testDefaultInit() {
        let f = TestFoo(build: { _ in })
        XCTAssertEqual(f.string, "string")
        XCTAssertNil(f.int)
    }
    
    func testSimpleInit() {
        let f = TestFoo {
            $0.string = "hello"
            $0.int = 42
        }
        
        XCTAssertEqual(f.string, "hello")
        XCTAssertEqual(f.int, 42)
    }
    
    func testChainedInit() {
        let f = TestFoo.builder()
            .string("hello")
            .int(42)
            .build()
        
        XCTAssertEqual(f.string, "hello")
        XCTAssertEqual(f.int, 42)
    }
    
    func testReusedBuilder() {
        var b = TestFoo.builder()
        b.string = "hello"
        
        let f1 = b.build()
        XCTAssertEqual(f1.string, "hello")
        XCTAssertNil(f1.int)
        
        b.string = "world"
        b.int = 42
        let f2 = b.build()
        
        XCTAssertEqual(f2.string, "world")
        XCTAssertEqual(f2.int, 42)
    }
    
    func testInnerBuilder() {
        let f = TestFoo.builder()
            .string("hello")
            .other({ $0.name = "world" })
            .build()
        
        XCTAssertEqual(f.string, "hello")
        XCTAssertNil(f.int)
        XCTAssertEqual(f.other.name, "world")
        XCTAssertNil(f.maybe)
    }
    
}

struct TestFoo: Buildable {
    
    let string: String
    let int: Int?
    let other: Other
    let maybe: Other?
    
    init(builder: Builder<TestFoo>) {
        self.string = builder.string ?? "string"
        self.int = builder.int
        self.other = builder.other ?? Other.buildDefault()
        self.maybe = builder.maybe
    }
    
}

struct Other: Buildable {
    let name: String
    
    init(builder: Builder<Other>) {
        name = builder.name ?? "name"
    }
}
