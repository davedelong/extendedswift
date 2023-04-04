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
    
    public var isSuperscript: Bool {
        switch self {
            case "\u{00B2}": return true
            case "\u{00B3}": return true
            case "\u{00B9}": return true
            case "\u{2070}"..."\u{207F}": return true
            default: return false
        }
    }
    
    public init?(ascii: Int) {
        guard let scalar = Unicode.Scalar(ascii) else { return nil }
        self.init(scalar)
    }
}
