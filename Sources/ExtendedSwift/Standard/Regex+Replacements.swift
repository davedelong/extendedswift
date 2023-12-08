//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/14/23.
//

import Foundation

extension String {
    
    // MARK: - First
    
    public func replacingFirstMatch<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) -> String {
        guard let match = try? regex.firstMatch(in: self) else { return self }
        let newValue = replacement(match)
        var copy = self
        copy.replaceSubrange(match.range, with: newValue)
        return copy
    }
    
    public func replacingFirstMatch<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) -> String {
        return replacingFirstMatch(of: regex, using: { replacement.buildReplacement($0) })
    }
    
    public func replacingFirstMatch<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) -> String {
        let replacement = Regex.Replacement(parts: builder())
        return self.replacingFirstMatch(of: regex, with: replacement)
    }
    
    public func replacingFirstMatch<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) -> String {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        return self.replacingFirstMatch(of: regex, with: replacement)
    }
    
    // MARK: - Last
    
    public func replacingLastMatch<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) -> String {
        guard let match = regex.lastMatch(in: self) else { return self }
        let newValue = replacement(match)
        var copy = self
        copy.replaceSubrange(match.range, with: newValue)
        return copy
    }
    
    public func replacingLastMatch<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) -> String {
        return replacingLastMatch(of: regex, using: { replacement.buildReplacement($0) })
    }
    
    public func replacingLastMatch<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) -> String {
        let replacement = Regex.Replacement(parts: builder())
        return self.replacingLastMatch(of: regex, with: replacement)
    }
    
    public func replacingLastMatch<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) -> String {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        return self.replacingLastMatch(of: regex, with: replacement)
    }
    
    // MARK: - All
    
    public func replacingAllMatches<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) -> String {
        self.replacing(regex, with: replacement)
    }
    
    public func replacingAllMatches<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) -> String {
        return self.replacing(regex, with: { replacement.buildReplacement($0) })
    }
    
    public func replacingAllMatches<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) -> String {
        let replacement = Regex.Replacement(parts: builder())
        return self.replacingAllMatches(of: regex, with: replacement)
    }
    
    public func replacingAllMatches<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) -> String {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        return self.replacingAllMatches(of: regex, with: replacement)
    }
    
    // MARK: - Mutating Versions
    
    // MARK: - First
    
    public mutating func replaceFirstMatch<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) {
        self = self.replacingFirstMatch(of: regex, using: replacement)
    }
    
    public mutating func replaceFirstMatch<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) {
        self = self.replacingFirstMatch(of: regex, with: replacement)
    }
    
    public mutating func replaceFirstMatch<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) {
        let replacement = Regex.Replacement(parts: builder())
        self.replaceFirstMatch(of: regex, with: replacement)
    }
    
    public mutating func replaceFirstMatch<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        self.replaceFirstMatch(of: regex, with: replacement)
    }
    
    // MARK: - Last
    
    public mutating func replaceLastMatch<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) {
        self = self.replacingLastMatch(of: regex, using: replacement)
    }
    
    public mutating func replaceLastMatch<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) {
        self = self.replacingLastMatch(of: regex, with: replacement)
    }
    
    public mutating func replaceLastMatch<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) {
        let replacement = Regex.Replacement(parts: builder())
        self.replaceLastMatch(of: regex, with: replacement)
    }
    
    public mutating func replaceLastMatch<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        self.replaceLastMatch(of: regex, with: replacement)
    }
    
    // MARK: - All
    
    public mutating func replaceAllMatches<Output>(of regex: Regex<Output>, using replacement: (Regex<Output>.Match) -> String) {
        self = self.replacingAllMatches(of: regex, using: replacement)
    }
    
    public mutating func replaceAllMatches<Output>(of regex: Regex<Output>, with replacement: Regex<Output>.Replacement) {
        self = self.replacingAllMatches(of: regex, with: replacement)
    }
    
    public mutating func replaceAllMatches<Output>(of regex: Regex<Output>, @Regex<Output>.ReplacementBuilder with builder: () -> [Regex<Output>.ReplacementPart]) {
        let replacement = Regex.Replacement(parts: builder())
        self.replaceAllMatches(of: regex, with: replacement)
    }
    
    public mutating func replaceAllMatches<Output>(of regex: Regex<Output>, with keyPath: KeyPath<Regex<Output>.Match, Substring>) {
        let replacement = Regex.Replacement(parts: [.matchPortion(keyPath)])
        self.replaceAllMatches(of: regex, with: replacement)
    }
    
}

extension Regex {
    
    public enum ReplacementPart {
        case literal(String)
        case matchPortion(KeyPath<Regex<Output>.Match, Substring>)
    }
    
    public struct Replacement: ExpressibleByStringInterpolation {
        
        public struct StringInterpolation: StringInterpolationProtocol {
            
            internal var parts = Array<ReplacementPart>()
            
            public init(literalCapacity: Int, interpolationCount: Int) { }
            
            public mutating func appendLiteral(_ literal: String) {
                parts.append(.literal(literal))
            }
            
            public mutating func appendInterpolation(_ keyPath: KeyPath<Regex<Output>.Match, Substring>) {
                parts.append(.matchPortion(keyPath))
            }
        }
        
        private let parts: Array<ReplacementPart>
        
        internal init(parts: Array<ReplacementPart>) {
            self.parts = parts
        }
        
        public init(stringLiteral value: StringLiteralType) {
            parts = [.literal(value)]
        }
        
        public init(stringInterpolation: StringInterpolation) {
            parts = stringInterpolation.parts
        }
        
        internal func buildReplacement(_ match: Regex<Output>.Match) -> String {
            var final = ""
            for part in parts {
                switch part {
                    case .literal(let s): final.append(s)
                    case .matchPortion(let kp): final.append(contentsOf: match[keyPath: kp])
                }
            }
            return final
        }
    }
    
    @resultBuilder
    public enum ReplacementBuilder {
        public static func buildExpression(_ expression: String) -> ReplacementPart {
            return .literal(expression)
        }
        
        public static func buildExpression(_ expression: KeyPath<Regex<Output>.Match, Substring>) -> ReplacementPart {
            return .matchPortion(expression)
        }
        
        public static func buildArray(_ components: [[ReplacementPart]]) -> [ReplacementPart] {
            return components.flattened()
        }
        
        public static func buildBlock(_ components: ReplacementPart...) -> [ReplacementPart] {
            return components
        }
    }
    
}
