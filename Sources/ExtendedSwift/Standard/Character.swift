//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Character {
    
    public var isASCIIDigit: Bool { isASCII && isWholeNumber }
    
    public var isAlphanumeric: Bool { isLetter || isNumber }
    
    public var isWhitespaceOrNewline: Bool { isWhitespace || isNewline }
    
    public init?(ascii: Int) {
        guard let scalar = Unicode.Scalar(ascii) else { return nil }
        self.init(scalar)
    }
}
