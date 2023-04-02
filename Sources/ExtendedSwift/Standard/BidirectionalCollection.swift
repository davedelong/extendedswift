//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension BidirectionalCollection {
    
    public var lastIndex: Index? {
        guard isNotEmpty else { return nil }
        return self.index(before: self.endIndex)
    }
    
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

extension BidirectionalCollection where Self: MutableCollection, Self.SubSequence == Self {
    
    public var last: Element? {
        get {
            guard let lastIndex else { return nil }
            return self[lastIndex]
        }
        set {
            if let newValue {
                if let lastIndex {
                    self[lastIndex] = newValue
                } else {
                    // self is empty; add/append the value??
                    print("Cannot append \(newValue) to empty collection of type \(type(of: self)). Please file a bug.")
                }
            } else {
                // remove the last value
                self.removeLast()
            }
        }
    }
    
}

/*
 Array and String both have discrete SubSequence types (ArraySlice and Substring),
 and therefore can't use the default implementation above.
 
 Since they're extremely common types, they deserve their own implementations
 */

extension Array {
    
    public var last: Element? {
        get {
            guard let lastIndex else { return nil }
            return self[lastIndex]
        }
        set {
            if let newValue {
                if let lastIndex {
                    self[lastIndex] = newValue
                } else {
                    self.append(newValue)
                }
            } else {
                self.removeLast()
            }
        }
    }
    
}

extension String {
    
    public var last: Element? {
        get {
            guard let lastIndex else { return nil }
            return self[lastIndex]
        }
        set {
            if let newValue {
                if let lastIndex {
                    self.replaceSubrange(lastIndex ... lastIndex, with: [newValue])
                } else {
                    self.append(newValue)
                }
            } else {
                self.removeLast()
            }
        }
    }
    
}
