//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension BidirectionalCollection {
    
    public var lastIndex: Index? { self.indices.last }
    
    public func last(_ k: Int) -> SubSequence {
        guard k > 0 else {
            return self[endIndex ..< endIndex]
        }
        
        if let start = self.index(self.endIndex, offsetBy: -k, limitedBy: self.startIndex) {
            return self[start ..< endIndex]
        } else {
            return self[...]
        }
    }
    
}

extension BidirectionalCollection where Self: RangeReplaceableCollection {
    
    public var last: Element? {
        get {
            guard let lastIndex else { return nil }
            return self[lastIndex]
        }
        set {
            if let newValue {
                if let lastIndex {
                    self.replaceSubrange(lastIndex ..< endIndex, with: [newValue])
                } else {
                    self = .init()
                    self.append(newValue)
                }
            } else {
                // remove the last value
                self.removeLast()
            }
        }
    }
    
}
