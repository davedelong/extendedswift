//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/14/23.
//

import XCTest
import ExtendedSwift

class RegexTests: XCTestCase {
    
    func testAllMatches() throws {
        let r = /\d+/
        
        let m1 = try r.allMatches(in: "123 456")
        XCTAssertEqual(m1.count, 2)
        
        let m2 = try r.allMatches(in: "hello, world")
        XCTAssertEqual(m2.count, 0)
    }
    
    func testReplacement() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replaceOccurrences(of: r1, with: "")
        XCTAssertEqual(s1, "bob")
        
        let s2 = "bob".replaceOccurrences(of: r1, with: "")
        XCTAssertEqual(s2, "bob")
    }
    
    func testReplacementInterpolation() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replaceOccurrences(of: r1, with: " \(\.1)")
        XCTAssertEqual(s1, "bob 123")
        let s2 = "bob123-456".replaceOccurrences(of: r1, with: " \(\.1)")
        XCTAssertEqual(s2, "bob 123- 456")
    }
    
    func testReplacementBuilder() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replaceOccurrences(of: r1, with: {
            " "
            \.1
        })
        XCTAssertEqual(s1, "bob 123")
    }
}
