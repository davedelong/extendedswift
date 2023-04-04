//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension Scanner where Element == Character {
    
    @discardableResult
    public mutating func scanDecimal() throws -> Decimal {
        let start = location
        let slice = try scanFloatingPointSequence()
        if let d = Decimal(string: String(slice)) { return d }
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    @discardableResult
    public mutating func scanDouble() throws -> Double {
        let start = location
        let slice = try scanFloatingPointSequence()
        if let d = Double(Substring(slice)) { return d }
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    @discardableResult
    public mutating func scanHexInt() throws -> Int {
        let start = location
        try scanElement("0" as Character)
        try scanElement(in: "xX")
        let slice = try scan(while: \.isHexDigit)
        if let i = Int(Substring(slice), radix: 16) { return i }
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    @discardableResult
    public mutating func scanInt() throws -> Int {
        let start = location
        try scanElement("-" as Character)
        let slice = try scan(while: \.isWholeNumber)
        if let i = Int(Substring(slice)) { return i }
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    @discardableResult
    public mutating func scanUInt() throws -> UInt {
        let start = location
        let slice = try scan(while: \.isWholeNumber)
        if let u = UInt(Substring(slice)) { return u }
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    private mutating func scanFloatingPointSequence() throws -> C.SubSequence {
        let start = location
        
        try scan(while: \.isWholeNumber)
        
        if let _ = try? scanElement("." as Character) {
            // consume fractional digits
            _ = try? scan(while: \.isWholeNumber)
        }
        
        let locationBeforeE = location
        if let _ = try? scanElement(in: "eE") {
            let locationOfExponent = location
            
            // there might be a "-" or "+" character preceding the exponent
            _ = try? scanElement(in: "-+")
            
            _ = try? scan(while: \.isWholeNumber)
            
            if location == locationOfExponent {
                // we didn't read anything after the [eE][-+]
                // so the entire exponent range is invalid
                location = locationBeforeE
            }
        }
        
        return data[start ..< location]
    }
    
}
