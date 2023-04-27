//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import XCTest

class CollectionTests: XCTestCase {
    
    func testIsNotEmpty() {
        XCTAssertFalse([].isNotEmpty)
        XCTAssertTrue([1, 2, 3].isNotEmpty)
        
        XCTAssertTrue([1, 2, 3][0 ..< 0].isEmpty)
        XCTAssertFalse([1, 2, 3][0 ..< 0].isNotEmpty)
    }
    
    func testAllPrefixes() {
        let p1 = "abcde".allPrefixes()
        XCTAssertEqual(p1.count, 5)
        XCTAssertEqual(p1[0], "a")
        XCTAssertEqual(p1[1], "ab")
        XCTAssertEqual(p1[2], "abc")
        XCTAssertEqual(p1[3], "abcd")
        XCTAssertEqual(p1[4], "abcde")
        
        let p2 = "a".allPrefixes()
        XCTAssertEqual(p2.count, 1)
        XCTAssertEqual(p2[0], "a")
        
        let p3 = Array<Character>().allPrefixes()
        XCTAssertEqual(p3.count, 0)
    }
    
    func testTrimming() {
        XCTAssertEqual("   abc   ".trimming(where: \.isWhitespace), "abc")
        XCTAssertEqual("   abc   ".trimmingPrefix(where: \.isWhitespace), "abc   ")
        XCTAssertEqual("   abc   ".trimmingSuffix(where: \.isWhitespace), "   abc")
        
        XCTAssertEqual("   ".trimming(where: \.isWhitespace), "")
        XCTAssertEqual("   ".trimmingPrefix(where: \.isWhitespace), "")
        XCTAssertEqual("   ".trimmingSuffix(where: \.isWhitespace), "")
    }
    
    func testLastK() {
        let s = "abc"
        XCTAssertEqual(s.last(-1), "")
        XCTAssertEqual(s.last(0), "")
        XCTAssertEqual(s.last(1), "c")
        XCTAssertEqual(s.last(2), "bc")
        XCTAssertEqual(s.last(3), "abc")
        XCTAssertEqual(s.last(4), "abc")
    }
}
