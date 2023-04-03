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

extension String {
    
    public struct MatchOption: Hashable {
        
        /// Normally, every occurrence of a backslash (`\`) followed by a character in pattern is replaced by that character.
        /// This is done to negate any special meaning for the character.  If this options is specified,
        /// a backslash character is treated as an ordinary character.
        public static let literalBackslashes = MatchOption(rawValue: FNM_NOESCAPE)
        
        /// Slash characters (`/`) in the string must be explicitly matched by slashes in pattern.
        /// If this flag is not set, then slashes are treated as regular characters and can be matched by wildcards (`*`).
        public static let literalSlashes = MatchOption(rawValue: FNM_PATHNAME)
        
        /// Leading periods (`.`) in the string must be explicitly matched by periods in pattern.  If this option is not set,
        /// then leading periods are treated as regular characters.  The definition of “leading” is related to the specification of ``.literalSlashes``.
        /// A period is always “leading” if it is the first character in string.  Additionally, if ``.literalSlashes`` is set,
        /// a period is leading if it immediately follows a slash.
        public static let period = MatchOption(rawValue: FNM_PERIOD)
        
        /// Matching is case insensitive
        public static let caseInsensitive = MatchOption(rawValue: FNM_CASEFOLD)
        
        let rawValue: Int32
        init(rawValue: Int32) { self.rawValue = rawValue }
    }
    
    public func matches(pattern: String, options: Set<MatchOption> = []) -> Bool {
        var allOptions: Int32 = 0
        for option in options {
            allOptions |= option.rawValue
        }
        
        let result = pattern.withCString { t in
            return self.withCString { c in
                return fnmatch(t, c, allOptions)
            }
        }
        return result == 0
    }
    
}

extension String.StringInterpolation {
    
    public mutating func appendInterpolation<Value>(describing value: Value?) {
        self.appendInterpolation(String(describing: value))
    }
    
}
