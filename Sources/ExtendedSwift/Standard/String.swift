//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension String {
    
    public func nilIfEmpty() -> String? {
        if isEmpty { return nil }
        return self
    }
    
    public func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func removingPrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) { return String(dropFirst(prefix.count)) }
        return self
    }
    
    public func removingSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) { return String(dropLast(suffix.count)) }
        return self
    }
    
    public func leadingPadded(toLength count: Int, with character: Character) -> String {
        let numberNeeded = count - self.count
        if numberNeeded <= 0 { return self }
        let prefix = String(repeating: character, count: numberNeeded)
        return prefix + self
    }
    
    public var withLeadingZeroesStripped: String {
        return String(trimmingPrefix(where: { $0 == "0" }))
    }
    
}

extension String.StringInterpolation {
    
    public mutating func appendInterpolation<Value>(describing value: Value?) {
        self.appendInterpolation(String(describing: value))
    }
    
}
