//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/25/23.
//

import XCTest
@testable import ExtendedSwift

func XCTAssertEqualPlists<T>(_ plist1: Any, _ plist2: T, file: StaticString = #file, line: UInt = #line) {
    let ns1 = plist1 as! NSObject
    let ns2 = plist2 as! NSObject
    
    XCTAssertEqual(ns1, ns2, file: file, line: line)
}

class PlistCodableTests: XCTestCase {
    
    func testSingleValue() throws {
        let e = try PlistEncoder().encode("Hello")
        XCTAssertEqualPlists(e, "Hello")
        
        let d = try PlistDecoder().decode(String.self, from: e)
        XCTAssertEqual(d, "Hello")
    }
    
    func testArray() throws {
        let e = try PlistEncoder().encode(["a", "b", "c"])
        XCTAssertEqualPlists(e, ["a", "b", "c"])
        
        let d = try PlistDecoder().decode(Array<String>.self, from: e)
        XCTAssertEqual(d, ["a", "b", "c"])
    }
    
    func testObject() throws {
        struct Foo: Codable, Equatable {
            let a: Int
            let b: String
        }
        
        let f = Foo(a: 42, b: "b")
        
        let e = try PlistEncoder().encode(f)
        XCTAssertEqualPlists(e, ["a": 42, "b": "b"])
        
        let d = try PlistDecoder().decode(Foo.self, from: e)
        XCTAssertEqual(d, f)
    }
    
    func testNestedObject() throws {
        struct Foo: Codable, Equatable {
            let a: Int
            let b: String
            let bar: Bar?
        }
        struct Bar: Codable, Equatable {
            let c: Array<String>
            let d: String?
        }
        
        
        let bar = Bar(c: ["a", "b"], d: nil)
        let foo = Foo(a: 42, b: "b", bar: bar)
        
        let e = try PlistEncoder().encode(foo)
        XCTAssertEqualPlists(e, [
            "a": 42,
            "b": "b",
            "bar": [
                "c": ["a", "b"]
            ]
        ])
        
        let d = try PlistDecoder().decode(Foo.self, from: e)
        XCTAssertEqual(d, foo)
    }
}
