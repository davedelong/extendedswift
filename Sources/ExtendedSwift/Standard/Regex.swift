//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Regex {
    
    public func allMatches(in s: String) throws -> Array<Match> {
        return try self.allMatches(in: s[...])
    }
    
    public func allMatches(in s: Substring) throws -> Array<Match> {
        var remaining = s
        var matches = Array<Match>()
        
        while let next = try self.firstMatch(in: remaining) {
            matches.append(next)
            
            let endOfMatch = next.range.upperBound
            
            if endOfMatch < remaining.endIndex {
                remaining = remaining[endOfMatch ..< remaining.endIndex]
            } else {
                break
            }
        }
        
        return matches
    }
    
}

extension String {
    
    public func replaceOccurrences<Output>(of regex: Regex<Output>, with replacement: RegexReplacement<Output>) -> String {
        return self.replacing(regex, with: { match in
            return replacement.buildReplacement(match)
        })
    }
    
    public func replaceOccurrences<Output>(of regex: Regex<Output>, @RegexReplacementBuilder<Output> with builder: () -> [RegexReplacementPart<Output>] ) -> String {
        let replacement = RegexReplacement(parts: builder())
        return self.replaceOccurrences(of: regex, with: replacement)
    }
    
}

public enum RegexReplacementPart<Output> {
    case literal(String)
    case matchPortion(KeyPath<Regex<Output>.Match, Substring>)
}

public struct RegexReplacement<Output>: ExpressibleByStringInterpolation {
    
    public struct StringInterpolation: StringInterpolationProtocol {
        
        internal var parts = Array<RegexReplacementPart<Output>>()
        
        public init(literalCapacity: Int, interpolationCount: Int) { }
        
        public mutating func appendLiteral(_ literal: String) {
            parts.append(.literal(literal))
        }
        
        public mutating func appendInterpolation(_ keyPath: KeyPath<Regex<Output>.Match, Substring>) {
            parts.append(.matchPortion(keyPath))
        }
    }
    
    private let parts: Array<RegexReplacementPart<Output>>
    
    internal init(parts: Array<RegexReplacementPart<Output>>) {
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
public enum RegexReplacementBuilder<Output> {
    public typealias Part = RegexReplacementPart<Output>
    
    public static func buildExpression(_ expression: String) -> Part {
        return .literal(expression)
    }
    
    public static func buildExpression(_ expression: KeyPath<Regex<Output>.Match, Substring>) -> Part {
        return .matchPortion(expression)
    }
    
    public static func buildArray(_ components: [[Part]]) -> [Part] {
        return components.flattened()
    }
    
    public static func buildBlock(_ components: Part...) -> [Part] {
        return components
    }
}
