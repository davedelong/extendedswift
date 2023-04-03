//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension RangeReplaceableCollection {
    
    public static func + (lhs: Self, rhs: Element) -> Self {
        var copy = lhs
        copy.append(rhs)
        return copy
    }
    
    public static func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
    
    public mutating func mutatingForEach(_ iterator: (inout Element) throws -> Void) rethrows {
        var copy = Self.init()
        for var item in self {
            try iterator(&item)
            copy.append(item)
        }
        self = copy
    }
    
    public mutating func mapInPlace(_ mapper: (Element) throws -> Element) rethrows {
        var copy = Self.init()
        for item in self {
            copy.append(try mapper(item))
        }
        self = copy
    }
    
}

extension RangeReplaceableCollection where Self: MutableCollection {
    
    public mutating func mutatingForEach(_ iterator: (inout Element) throws -> Void) rethrows {
        for i in self.indices {
            var item = self[i]
            try iterator(&item)
            self[i] = item
        }
    }
    
    public mutating func mapInPlace(_ mapper: (Element) throws -> Element) rethrows {
        var index = startIndex
        while index < endIndex {
            self[index] = try mapper(self[index])
            index = self.index(after: index)
        }
    }
    
}
