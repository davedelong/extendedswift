//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/14/23.
//

import Foundation

/// A Bimap is like a dictionary, except that it's bidirectional:
/// you can look up keys based on values as well.
///
/// It uses twice as much storage as a regular dictionary
public struct Bimap<Left: Hashable, Right: Hashable> {
    
    private var leftToRight = Dictionary<Left, Right>()
    private var rightToLeft = Dictionary<Right, Left>()
    
    public init() { }
    
    public subscript(key: Left) -> Right? {
        get {
            return leftToRight[key]
        }
        set {
            if let newB = newValue {
                let oldB = leftToRight.removeValue(forKey: key)
                leftToRight[key] = newB
                
                if let oldB { rightToLeft.removeValue(forKey: oldB) }
                rightToLeft[newB] = key
            } else {
                if let oldB = leftToRight.removeValue(forKey: key) {
                    rightToLeft.removeValue(forKey: oldB)
                }
            }
        }
    }
    
    public subscript(key: Right) -> Left? {
        get {
            return rightToLeft[key]
        }
        set {
            if let newA = newValue {
                let oldA = rightToLeft.removeValue(forKey: key)
                rightToLeft[key] = newA
                
                if let oldA { leftToRight.removeValue(forKey: oldA) }
                leftToRight[newA] = key
            } else {
                if let oldA = rightToLeft.removeValue(forKey: key) {
                    leftToRight.removeValue(forKey: oldA)
                }
            }
        }
    }
}

extension Bimap: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Left, Right)...) {
        self.init()
        for (l, r) in elements {
            self[l] = r
        }
    }
    
}
