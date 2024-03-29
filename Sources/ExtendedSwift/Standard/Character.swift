//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Character {
    
    public static var newline: Self { "\n" }
    public static var space: Self { " " }
    public static var hyphen: Self { "-" }
    public static var comma: Self { "," }
    public static var backslash: Self { "\\" }
    public static var doubleQuote: Self { "\"" }
    
    public var isASCIIDigit: Bool { isASCII && isWholeNumber }
    
    public var isAlphanumeric: Bool { isLetter || isNumber }
    
    public var isWhitespaceOrNewline: Bool { isWhitespace || isNewline }
    
    public var isOctalDigit: Bool { octalDigitValue != nil }
    
    public var octalDigitValue: Int? {
        guard let hexDigitValue else { return nil }
        guard hexDigitValue >= 0 && hexDigitValue < 8 else { return nil }
        return hexDigitValue
    }
    
    public var isSuperscript: Bool {
        switch self {
            case "\u{00B2}": return true
            case "\u{00B3}": return true
            case "\u{00B9}": return true
            case "\u{0670}": return true
            case "\u{0711}": return true
            case "\u{2070}"..."\u{207F}": return true
            default: return false
        }
    }
    
    public var isSubscript: Bool {
        switch self {
            case "\u{0656}": return true
            case "\u{1D62}"..."\u{1D6A}": return true
            case "\u{2080}"..."\u{209C}": return true
            case "\u{2C7C}": return true
            default: return false
        }
    }
    
    public init?(ascii: Int) {
        guard let scalar = Unicode.Scalar(ascii) else { return nil }
        self.init(scalar)
    }
}
