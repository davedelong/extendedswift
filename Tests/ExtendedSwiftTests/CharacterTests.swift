//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import ExtendedSwift
import XCTest

class CharacterTests: XCTestCase {
    
    func testIsASCIIDigit() {
        for character in "0123456789" {
            XCTAssertTrue(character.isASCIIDigit)
        }
        
        for character in "abcdefghijklmnopqurstuvwxyz" {
            XCTAssertFalse(character.isASCIIDigit)
        }
        
        for character in "٠١٢٣٤٥٦٧٨٩๐๑๒๓๔๕๖๗๘๙" {
            XCTAssertTrue(character.isWholeNumber)
            XCTAssertFalse(character.isASCIIDigit)
        }
    }
    
}
