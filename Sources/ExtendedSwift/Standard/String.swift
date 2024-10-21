//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension String {
    
    public static var newline: String { "\n" }
    public static var empty: String { "" }
    public static var space: String { " " }
    public static var hyphen: String { "-" }
    public static var comma: String { "," }
    public static var doubleQuote: String { "\"" }
    
    public func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func trimming(_ string: String) -> String {
        return self.removingPrefix(string).removingSuffix(string)
    }
    
    public mutating func removePrefix(_ prefix: String) {
        self = self.removingPrefix(prefix)
    }
    
    public mutating func removeSuffix(_ suffix: String) {
        self = self.removingSuffix(suffix)
    }
    
    public func removingPrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) { return String(dropFirst(prefix.count)) }
        return self
    }
    
    public func removingSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) { return String(dropLast(suffix.count)) }
        return self
    }
    
    public func paddingLeading(toLength count: Int, with character: Character) -> String {
        let numberNeeded = count - self.count
        if numberNeeded <= 0 { return self }
        let prefix = String(repeating: character, count: numberNeeded)
        return prefix + self
    }
    
    public func strippingLeadingZeroes() -> String {
        return String(trimmingPrefix(where: { $0 == "0" }))
    }
    
    public init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        guard let s = String(data: data, encoding: .utf8) else { return nil }
        self = s
    }
    
    public init?(cString: UnsafePointer<CChar>, maxLength: Int) {
        var characters = Array<CChar>()
        let buffer = UnsafeBufferPointer(start: cString, count: maxLength)
        for character in buffer {
            if character == 0 { break }
            characters.append(character)
        }
        characters.append(0)
        self.init(utf8String: characters)
    }
    
    public func tokenize() -> Array<String> {
        var terms = Array<String>()
        var current = ""
        
        var isCurrentlyEscaping = false
        var isInsideQuote = false
        
        for character in self {
            if isCurrentlyEscaping {
                isCurrentlyEscaping = false
                current.append(character)
            } else if character == .backslash {
                isCurrentlyEscaping = true
            } else if character == .doubleQuote {
                if isInsideQuote {
                    terms.append(current)
                    current = ""
                }
                isInsideQuote.toggle()
            } else if isInsideQuote {
                current.append(character)
            } else if character.isWhitespace == false {
                current.append(character)
            } else {
                // it's whitespace
                if current.isEmpty == false {
                    terms.append(current)
                }
                current = ""
            }
        }
        if current.isEmpty == false {
            terms.append(current)
        }
        return terms
    }
    
}

extension StringProtocol {
    
    public func cleanedQuotedString() -> String? {
        var characters = Array<Character>()
        
        guard self.hasPrefix(.doubleQuote) && self.hasSuffix(.doubleQuote) else { return nil }
        
        var isEscaped = false
        for character in self.dropFirst().dropLast() {
            if isEscaped {
                characters.append(character)
                isEscaped = false
            } else if character == .backslash {
                isEscaped = true
            } else {
                characters.append(character)
            }
        }
        
        return String(characters)
    }
    
}

// Sadly, this causes too may problems
//extension String: RawRepresentable {
//    
//    public var rawValue: String { self }
//    
//    public init(rawValue: String) { self = rawValue }
//    
//}

extension String {
    
    public static func longestCommonPrefix<C: Collection>(of strings: C) -> String? where C.Element: Collection, C.Element.Element == Character {
        guard strings.isNotEmpty else { return nil }
        if strings.count == 1 { return String(strings.first!) }
        
        var otherSlices = strings.map { $0[...] }
        
        let first = otherSlices.removeFirst()
        let otherCount = otherSlices.count
        var currentIndex = first.startIndex
        while currentIndex < first.endIndex {
            let character = first[currentIndex]
            
            for i in 0 ..< otherCount {
                if otherSlices[i].isEmpty {
                    // cannot pop
                    return String(first[first.startIndex ..< currentIndex])
                } else {
                    let sliceChar = otherSlices[i].removeFirst()
                    if sliceChar != character {
                        return String(first[first.startIndex ..< currentIndex])
                    }
                }
            }
            
            currentIndex = first.index(after: currentIndex)
        }
        // got all the way to the end of the first string without finding a mismatch
        // the first string is the match
        return String(first)
    }
    
    public static func longestCommonSuffix<C: Collection>(of strings: C) -> String? where C.Element == Self {
        let reversed: Array<ReversedCollection<Self>> = strings.map { $0.reversed() }
        guard let prefix = longestCommonPrefix(of: reversed) else { return nil }
        return String(prefix.reversed())
    }
}

extension String {
    
    public struct MatchOption: Hashable, RawRepresentable {
        
        /// Normally, every occurrence of a backslash (`\`) followed by a character in pattern is replaced by that character.
        /// This is done to negate any special meaning for the character.  If this options is specified,
        /// a backslash character is treated as an ordinary character.
        public static let literalBackslashes = MatchOption(rawValue: FNM_NOESCAPE)
        
        /// When specified, slash characters (`/`) in the string must be explicitly matched by slashes in pattern.
        /// If this option is not set, then slashes are treated as regular characters and can be matched by wildcards (`*`).
        public static let filePath = MatchOption(rawValue: FNM_PATHNAME)
        
        /// Leading periods (`.`) in the string must be explicitly matched by periods in pattern.  If this option is not set,
        /// then leading periods are treated as regular characters.  The definition of “leading” is related to the specification of ``.filePath``.
        /// A period is always “leading” if it is the first character in string.  Additionally, if ``.filePath`` is set,
        /// a period is leading if it immediately follows a slash.
        public static let period = MatchOption(rawValue: FNM_PERIOD)
        
        /// Matching is case insensitive
        public static let caseInsensitive = MatchOption(rawValue: FNM_CASEFOLD)
        
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
    }
    
    /// Match the receiver to a pattern, following the conventions of `fnmatch`
    ///
    /// See `man fnmatch` for specific details.
    public func matches(pattern: String, options: Set<MatchOption> = []) -> Bool {
        let result = pattern.withCString { t in
            return self.withCString { c in
                return fnmatch(t, c, options.bitmask)
            }
        }
        return result == 0
    }
    
}

extension String.Encoding {
    
    public var byteOrderMark: Data? {
        guard let aData = "a".data(using: self) else { return nil }
        guard let aaData = "aa".data(using: self) else { return nil }
        
        let singleALength = aaData.count - aData.count
        let bomLength = aData.count - singleALength
        if bomLength == 0 { return nil }
        
        return Data(aData.prefix(bomLength))
    }
    
}
