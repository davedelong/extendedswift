//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Regex {
    
    public struct MatchSequence: Sequence {
        public typealias Element = Match
        
        internal let regex: Regex
        internal let source: Substring
        
        public func makeIterator() -> MatchIterator {
            return MatchIterator(regex: regex, source: source)
        }
        
    }
    
    public struct MatchIterator: IteratorProtocol {
        public typealias Element = Match
        
        internal let regex: Regex
        internal var source: Substring
        
        public mutating func next() -> Match? {
            guard let next = try? regex.firstMatch(in: source) else {
                return nil
            }
            
            let endOfMatch = next.range.upperBound
            
            if endOfMatch < source.endIndex {
                source = source[endOfMatch ..< source.endIndex]
            } else {
                source = source[source.endIndex...]
            }
            
            return next
        }
        
    }
    
    public func lastMatch(in s: String) throws -> Match? {
        return try self.lastMatch(in: s[...])
    }
    
    public func lastMatch(in s: Substring) throws -> Match? {
        var previous: Match?
        for match in self.matches(in: s) {
            previous = match
        }
        return previous
    }
    
    public func allMatches(in s: String) throws -> Array<Match> {
        return try self.allMatches(in: s[...])
    }
    
    public func allMatches(in s: Substring) throws -> Array<Match> {
        var matches = Array<Match>()
        for match in self.matches(in: s) {
            matches.append(match)
        }
        return matches
    }
    
    public func matches(in s: String) -> MatchSequence {
        return MatchSequence(regex: self, source: s[...])
    }
    
    public func matches(in s: Substring) -> MatchSequence {
        return MatchSequence(regex: self, source: s)
    }
    
}
