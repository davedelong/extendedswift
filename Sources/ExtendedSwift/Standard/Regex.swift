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
        internal let allowOverlaps: Bool
        
        public func makeIterator() -> MatchIterator {
            return MatchIterator(regex: regex, source: source, allowOverlaps: allowOverlaps)
        }
        
    }
    
    public struct MatchIterator: IteratorProtocol {
        public typealias Element = Match
        
        internal let regex: Regex
        internal var source: Substring
        internal let allowOverlaps: Bool
        
        public mutating func next() -> Match? {
            guard let next = try? regex.firstMatch(in: source) else {
                return nil
            }
            
            if allowOverlaps {
                let startOfMatch = next.range.lowerBound
                let startOfElementAfter = source.index(after: startOfMatch)
                
                if startOfElementAfter < source.endIndex {
                    source = source[startOfElementAfter ..< source.endIndex]
                } else {
                    source = source[source.endIndex...]
                }
            } else {
                let endOfMatch = next.range.upperBound
                
                if endOfMatch < source.endIndex {
                    source = source[endOfMatch ..< source.endIndex]
                } else {
                    source = source[source.endIndex...]
                }
            }
            
            return next
        }
        
    }
    
    public func lastMatch(in s: String) -> Match? {
        return self.lastMatch(in: s[...])
    }
    
    public func lastMatch(in s: Substring) -> Match? {
        var previous: Match?
        for match in self.matches(in: s, allowOverlaps: true) {
            previous = match
        }
        return previous
    }
    
    public func allMatches(in s: String, allowOverlaps: Bool = false) -> Array<Match> {
        return Array(self.matches(in: s, allowOverlaps: allowOverlaps))
    }
    
    public func allMatches(in s: Substring, allowOverlaps: Bool = false) -> Array<Match> {
        return Array(self.matches(in: s, allowOverlaps: allowOverlaps))
    }
    
    public func matches(in s: String, allowOverlaps: Bool = false) -> MatchSequence {
        return MatchSequence(regex: self, source: s[...], allowOverlaps: allowOverlaps)
    }
    
    public func matches(in s: Substring, allowOverlaps: Bool = false) -> MatchSequence {
        return MatchSequence(regex: self, source: s, allowOverlaps: allowOverlaps)
    }
    
}
