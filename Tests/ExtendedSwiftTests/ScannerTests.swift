//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/26/23.
//

import XCTest
import ExtendedSwift

class ScannerTests: XCTestCase {
    
    func testPeek() throws {
        var scanner = Scanner(data: "abc")
        XCTAssertEqual(scanner.peekElement(), "a")
        XCTAssertEqual(scanner.peekElement(), "a")
        XCTAssertEqual(scanner.peekElement(), "a")
        
        try scanner.scanElement()
        try scanner.scanElement()
        try scanner.scanElement()
        
        XCTAssertEqual(scanner.peekElement(), nil)
        
        scanner = Scanner(data: "")
        XCTAssertEqual(scanner.peekElement(), nil)
    }
    
    func testScanElement() throws {
        var scanner = Scanner(data: "abc")
        XCTAssertEqual(try scanner.scanElement(), "a")
        XCTAssertEqual(try scanner.scanElement(), "b")
        XCTAssertEqual(try scanner.scanElement(), "c")
        XCTAssertThrowsError(try scanner.scanElement())
    }
    
    func testScanWhere() throws {
        var scanner = Scanner(data: "abAB")
        XCTAssertEqual(try scanner.scanElement(where: \.isLowercase), "a")
        XCTAssertEqual(try scanner.scanElement(where: \.isLowercase), "b")
        XCTAssertThrowsError(try scanner.scanElement(where: \.isLowercase))
    }
    
    func testScanWhile() throws {
        var scanner = Scanner(data: "abAB")
        XCTAssertEqual(try scanner.scan(while: \.isUppercase), "")
        XCTAssertEqual(try scanner.scan(while: \.isLowercase), "ab")
        XCTAssertEqual(try scanner.scan(while: \.isLowercase), "")
        XCTAssertEqual(try scanner.scan(while: \.isUppercase), "AB")
        XCTAssertThrowsError(try scanner.scan(while: \.isLowercase))
    }
    
    func testScanCount() throws {
        var scanner = Scanner(data: "abc")
        XCTAssertEqual(try scanner.scan(count: 2), "ab")
        XCTAssertThrowsError(try scanner.scan(count: 2))
        XCTAssertEqual(try scanner.scan(count: 1), "c")
    }
    
    func testScanCountWhere() throws {
        var scanner = Scanner(data: "abcABC")
        XCTAssertEqual(try scanner.scan(count: 2, where: \.isLowercase), "ab")
        XCTAssertThrowsError(try scanner.scan(count: 2, where: \.isLowercase))
        XCTAssertEqual(try scanner.scan(count: 1, where: \.isLowercase), "c")
        XCTAssertThrowsError(try scanner.scan(count: 4, where: \.isUppercase))
        XCTAssertEqual(try scanner.scan(count: 3, where: \.isUppercase), "ABC")
    }
    
    func testScanCollection() throws {
        var scanner = Scanner(data: "abcABC")
        XCTAssertEqual(scanner.scan("abc"), true)
        XCTAssertThrowsError(try scanner.scan("abc"))
        XCTAssertEqual(scanner.scan("ABC"), true)
    }
    
    func testScanUpTo() throws {
        var scanner = Scanner(data: "abcABC")
        XCTAssertEqual(try scanner.scan(upTo: "A" as Character), "abc")
        XCTAssertEqual(try scanner.scanElement("A"), "A")
        
        XCTAssertThrowsError(try scanner.scan(upTo: "D" as Character))
        
        scanner = Scanner(data: "abcABABC")
        XCTAssertEqual(try scanner.scan(upTo: "A", including: true), "abcA")
        XCTAssertEqual(try scanner.scan(upTo: "C", including: true), "BABC")
    }
    
    func testScanUpToCollection() throws {
        var scanner = Scanner(data: "abcABABC")
        XCTAssertEqual(try scanner.scan(upTo: "AB"), "abc")
        XCTAssertEqual(try scanner.scan(upTo: "AB"), "")
        XCTAssertEqual(try scanner.scan(upTo: "ABC"), "AB")
        XCTAssertThrowsError(try scanner.scan(upTo: "ABCD"))
        
        scanner = Scanner(data: "abcABABC")
        XCTAssertEqual(try scanner.scan(upTo: "ABC"), "abcAB")
        XCTAssertEqual(try scanner.scan(upTo: ""), "")
        
        scanner = Scanner(data: "abcABABC")
        XCTAssertEqual(try scanner.scan(upTo: "AB", including: true), "abcAB")
        XCTAssertEqual(try scanner.scan(upTo: "BC", including: true), "ABC")
    }
    
    func testScanIn() throws {
        var scanner = Scanner(data: "abcABC")
        XCTAssertEqual(try scanner.scanElement(in: "cba"), "a")
        XCTAssertThrowsError(try scanner.scanElement(in: "CBA"))
    }
    
    func testScanFrom() throws {
        var scanner = Scanner(data: "abcABC")
        XCTAssertEqual(try scanner.scan(anyFrom: "gfedcba"), "abc")
        XCTAssertEqual(try scanner.scan(anyFrom: "gfedcba"), "")
        XCTAssertEqual(try scanner.scan(anyFrom: "GFEDCBA"), "ABC")
        XCTAssertThrowsError(try scanner.scan(anyFrom: "GFEDCBA"))
    }
    
    func testScanQuotedString() throws {
        let source = #""test""#
        var scanner = Scanner(data: source)
        XCTAssertEqual(try scanner.scanQuotedString(), source[...])
        
        let escaped = #""ab\"cd""#
        scanner = Scanner(data: escaped)
        XCTAssertEqual(try scanner.scanQuotedString(), escaped[...])
        
        scanner = Scanner(data: "abc")
        XCTAssertThrowsError(try scanner.scanQuotedString())
    }
    
    func testScanString() throws {
        var scanner = Scanner(data: "abc")
        XCTAssertTrue(try scanner.scan("abc", options: []))
        
        scanner = Scanner(data: "ábc")
        XCTAssertTrue(try scanner.scan("abc", options: [.diacriticInsensitive]))
        
        scanner = Scanner(data: "ABC")
        XCTAssertTrue(try scanner.scan("abc", options: [.caseInsensitive]))
        
        scanner = Scanner(data: "ÁBC")
        XCTAssertTrue(try scanner.scan("abc", options: [.diacriticInsensitive, .caseInsensitive]))
        
        scanner = Scanner(data: "ábc")
        XCTAssertThrowsError(try scanner.scan("abc", options: []))
    }
    
    func testScanDecimal() throws {
        var scanner = Scanner(data: "0.3a")
        XCTAssertEqual(try scanner.scanDecimal(), Decimal(0.3))
        XCTAssertEqual(try scanner.scanElement(), "a")
        
        scanner = Scanner(data: "abc")
        XCTAssertThrowsError(try scanner.scanDecimal())
    }
    
    func testScanDouble() throws {
        var scanner = Scanner(data: "0.1")
        XCTAssertEqual(try scanner.scanDouble(), 0.1)
        XCTAssertTrue(scanner.isAtEnd)
        
        scanner = Scanner(data: "-0.1")
        XCTAssertEqual(try scanner.scanDouble(), -0.1)
        XCTAssertTrue(scanner.isAtEnd)
        
        scanner = Scanner(data: "-0.1e0")
        XCTAssertEqual(try scanner.scanDouble(), -0.1)
        XCTAssertTrue(scanner.isAtEnd)
        
        scanner = Scanner(data: "-0.1e+0")
        XCTAssertEqual(try scanner.scanDouble(), -0.1)
        XCTAssertTrue(scanner.isAtEnd)
        
        scanner = Scanner(data: "-0.1E-0")
        XCTAssertEqual(try scanner.scanDouble(), -0.1)
        XCTAssertTrue(scanner.isAtEnd)
        
        scanner = Scanner(data: "-0.1e")
        XCTAssertEqual(try scanner.scanDouble(), -0.1)
        XCTAssertFalse(scanner.isAtEnd)
        XCTAssertEqual(try scanner.scanElement(), "e")
        
        scanner = Scanner(data: "abc")
        XCTAssertThrowsError(try scanner.scanDouble())
    }
    
    func testScanHexInt() throws {
        var scanner = Scanner(data: "0x0")
        XCTAssertEqual(try scanner.scanHexInt(), 0)
        
        scanner = Scanner(data: "0x1g")
        XCTAssertEqual(try scanner.scanHexInt(), 1)
        XCTAssertEqual(try scanner.scanElement(), "g")
        
        scanner = Scanner(data: "0x")
        XCTAssertThrowsError(try scanner.scanHexInt())
        
        scanner = Scanner(data: "0")
        XCTAssertThrowsError(try scanner.scanHexInt())
        
        // this value is too large to fit in an Int
        scanner = Scanner(data: "0x012345678901234567890123456789")
        XCTAssertThrowsError(try scanner.scanHexInt())
    }
    
    func testScanInt() throws {
        var scanner = Scanner(data: "1234")
        XCTAssertEqual(try scanner.scanInt(), 1234)
        
        scanner = Scanner(data: "-1234")
       XCTAssertEqual(try scanner.scanInt(), -1234)
        
        scanner = Scanner(data: "123f")
        XCTAssertEqual(try scanner.scanInt(), 123)
        XCTAssertEqual(try scanner.scanElement(), "f")
        
        scanner = Scanner(data: "abc")
        XCTAssertThrowsError(try scanner.scanInt())
        
        // this value is too large to fit in an Int
        scanner = Scanner(data: "123456789012345678901234567890")
        XCTAssertThrowsError(try scanner.scanInt())
    }
    
    func testScanUInt() throws {
        var scanner = Scanner(data: "1234")
        XCTAssertEqual(try scanner.scanUInt(), 1234)
        
        scanner = Scanner(data: "-1234")
       XCTAssertThrowsError(try scanner.scanUInt())
        
        scanner = Scanner(data: "123f")
        XCTAssertEqual(try scanner.scanUInt(), 123)
        XCTAssertEqual(try scanner.scanElement(), "f")
        
        scanner = Scanner(data: "abc")
        XCTAssertThrowsError(try scanner.scanUInt())
        
        // this value is too large to fit in an UInt
        scanner = Scanner(data: "123456789012345678901234567890")
        XCTAssertThrowsError(try scanner.scanUInt())
    }
    
}
