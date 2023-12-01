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
    
    public mutating func mutatingMap<V>(_ iterator: (inout Element) throws -> V) rethrows -> Array<V> {
        var final = Array<V>()
        for index in self.indices {
            var item = self[index]
            final.append(try iterator(&item))
        }
        return final
    }
    
    public mutating func mutatingForEach(_ iterator: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            var item = self[index]
            try iterator(&item)
            
            let after = self.index(after: index)
            self.replaceSubrange(index ..< after, with: [item])
        }
    }
    
    public mutating func mapInPlace(_ mapper: (Element) throws -> Element) rethrows {
        var copy = Self.init()
        for item in self {
            copy.append(try mapper(item))
        }
        self = copy
    }
    
    public init<S: AsyncSequence>(sequence: S) async throws where S.Element == Element {
        self.init()
        for try await item in sequence {
            self.append(item)
        }
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
