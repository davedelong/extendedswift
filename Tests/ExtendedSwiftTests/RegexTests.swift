//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/14/23.
//

import XCTest
import ExtendedSwift

class RegexTests: XCTestCase {
    
    func testLastMatch() throws {
        let r = /(\d+)/
        if let m1 = r.lastMatch(in: "123 456") {
            XCTAssertEqual(m1.1, "6")
        } else {
            XCTFail()
        }
    }
    
    func testAllMatches() throws {
        let r = /\d+/
        
        let m1 = r.allMatches(in: "123 456")
        XCTAssertEqual(m1.count, 2)
        
        let m2 = r.allMatches(in: "hello, world")
        XCTAssertEqual(m2.count, 0)
        
        let r2 = /^ab/
        let m3 = r2.allMatches(in: "abab")
        XCTExpectFailure("All matches for anchored regexes do not work properly")
        XCTAssertEqual(m3.count, 1)
    }
    
    func testFirstReplacement() throws {
        let r = /\d+/
        let s1 = "123 456".replacingFirstMatch(of: r, with: "bob")
        XCTAssertEqual(s1, "bob 456")
    }
    
    func testLastReplacement() throws {
        let r = /\d+/
        let s1 = "123 456".replacingLastMatch(of: r, with: "bob")
        XCTAssertEqual(s1, "123 45bob")
    }
    
    func testReplacement() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replacingAllMatches(of: r1, with: "")
        XCTAssertEqual(s1, "bob")
        
        let s2 = "bob".replacingAllMatches(of: r1, with: "")
        XCTAssertEqual(s2, "bob")
    }
    
    func testReplacementInterpolation() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replacingAllMatches(of: r1, with: " \(\.1)")
        XCTAssertEqual(s1, "bob 123")
        let s2 = "bob123-456".replacingAllMatches(of: r1, with: " \(\.1)")
        XCTAssertEqual(s2, "bob 123- 456")
    }
    
    func testReplacementBuilder() throws {
        let r1 = /(\d+)/
        let s1 = "bob123".replacingAllMatches(of: r1, with: {
            " "
            \.1
        })
        XCTAssertEqual(s1, "bob 123")
    }
}
