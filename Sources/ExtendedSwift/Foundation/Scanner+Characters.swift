//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension Scanner where Element == Character {
    
    @discardableResult
    public mutating func scanQuotedString() throws -> C.SubSequence {
        let start = location
        
        let doubleQuote = Character.doubleQuote
        let backslash = Character.backslash
        
        do {
            let openQuote = try self.scanElement(doubleQuote)
            
            var isEscaped = false
            while true {
                let next = try self.scanElement()
                if isEscaped {
                    isEscaped = false
                } else if next == backslash {
                    isEscaped = true
                } else if next == doubleQuote {
                    // the end of the quoted string
                    break
                }
            }
            
            return data[start ..< location]
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scan<S: StringProtocol>(_ other: S, options: String.CompareOptions) throws -> Bool {
        let start = location
        let characterCount = other.count
        let slice = try scan(count: characterCount)
        
        let stringSlice = Substring(slice)
        if other.compare(stringSlice, options: options, range: nil, locale: nil) == .orderedSame {
            return true
        }
        
        location = start
        throw ScannerError.invalidSequence(slice)
    }
    
    @discardableResult
    public mutating func scanDecimal() throws -> Decimal {
        let start = location
        do {
            let slice = try scanFloatingPointSequence()
            if slice.isNotEmpty, let d = Decimal(string: String(slice)) { return d }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scanDouble() throws -> Double {
        let start = location
        do {
            let slice = try scanFloatingPointSequence()
            if slice.isNotEmpty, let d = Double(Substring(slice)) { return d }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scanHexInt() throws -> Int {
        let start = location
        do {
            try scanElement("0" as Character)
            try scanElement(in: "xX")
            let slice = try scan(while: \.isHexDigit)
            if slice.isNotEmpty, let i = Int(Substring(slice), radix: 16) { return i }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scanOctInt() throws -> Int {
        let start = location
        do {
            try scanElement("0" as Character)
            try scanElement(in: "oO")
            let slice = try scan(while: \.isOctalDigit)
            if slice.isNotEmpty, let i = Int(Substring(slice), radix: 8) { return i }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scanInt() throws -> Int {
        let start = location
        do {
            _ = try? scanElement("-" as Character)
            try scan(while: \.isWholeNumber)
            let slice = data[start ..< location]
            if slice.isNotEmpty, let i = Int(Substring(slice)) { return i }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scanUInt() throws -> UInt {
        let start = location
        do {
            let slice = try scan(while: \.isWholeNumber)
            if slice.isNotEmpty, let u = UInt(Substring(slice)) { return u }
            throw ScannerError.invalidSequence(slice)
        } catch {
            location = start
            throw error
        }
    }
    
    private mutating func scanFloatingPointSequence() throws -> C.SubSequence {
        let start = location
        
        _ = try? scanElement("-" as Character)
        
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
