//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Collection {
    
    public func trimmingPrefix(where matches: (Element) -> Bool) -> SubSequence {
        var start = startIndex
        
        while matches(self[start]) {
            start = self.index(after: start)
            if start == endIndex {
                // we've trimmed the whole thing
                return self[startIndex ..< startIndex]
            }
        }
        
        return self[start ..< endIndex]
    }
    
}

extension BidirectionalCollection {
    
    public func trimmingSuffix(where matches: (Element) -> Bool) -> SubSequence {
        if isEmpty { return self[startIndex ..< startIndex] }
        
        guard var end = lastIndex else { return self[...] }
        
        while matches(self[end]) {
            if end > startIndex {
                end = self.index(before: end)
            } else if end <= startIndex {
                // we've trimmed the whole thing
                return self[startIndex ..< startIndex]
            }
        }
        
        return self[startIndex ... end]
    }
    
    public func trimming(where matches: (Element) -> Bool) -> SubSequence {
        return self.trimmingPrefix(where: matches)
                   .trimmingSuffix(where: matches)
    }
    
}
