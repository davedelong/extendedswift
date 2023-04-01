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
