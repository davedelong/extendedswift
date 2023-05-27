//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import Algorithms

/*
 TODO: removingPrefix, removingSuffix, hasPrefix, hasSuffix
 TODO: removePrefix, removeSuffix where Self == SubSequence ?
 */

extension Collection {
    
    public func trimmingPrefix(where matches: (Element) -> Bool) -> SubSequence {
        return self.trimmingPrefix(while: matches)
    }
    
}

extension BidirectionalCollection {
    
    public func trimmingSuffix(where matches: (Element) -> Bool) -> SubSequence {
        return self.trimmingSuffix(while: matches)
    }
    
    public func trimming(where matches: (Element) -> Bool) -> SubSequence {
        return self.trimming(while: matches)
    }
    
}
