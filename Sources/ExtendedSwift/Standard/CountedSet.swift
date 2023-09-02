//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/19/23.
//

import Foundation

extension Collection where Element: Hashable {
    
    @available(*, deprecated, renamed: "elementCounts()")
    public func frequencies() -> CountedSet<Element> {
        return CountedSet(self)
    }
    
    public func elementCounts() -> CountedSet<Element> {
        return CountedSet(self)
    }
    
}

/// An unordered data structure that keeps a count of all the elements that are inserted into it
public struct CountedSet<Element: Hashable> {
    
    internal typealias Storage = Dictionary<Element, Int>
    
    fileprivate var storage: Storage
    
    internal init(storage: Storage) {
        self.storage = storage
    }
    
    public init() {
        storage = [:]
    }
    
    public init(_ other: some Sequence<Element>) {
        self.init()
        for item in other {
            self.insert(item)
        }
    }
    
    /// Whether there are any elements in the set
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool { storage.isEmpty }
    
    /// The total number of elements in the set
    ///
    /// - Complexity: O(*n*), where *n* is the number of unique elements.
    public var count: Int { storage.values.sum() ?? 0 }
    
    /// Whether an element exists in the set
    /// - Parameter element: The element to be located
    /// - Returns: `true` if the element exists in the set; `false` otherwise.
    /// - Complexity: O(1)
    public func contains(_ element: Element) -> Bool {
        return count(for: element) > 0
    }
    
    /// Retrieve the number of times an element has been inserted into the set
    /// - Parameter element: The element to be located
    /// - Returns: The number of times the element has inserted into the set
    /// - Complexity: O(1)
    public func count(for element: Element) -> Int {
        return storage[element, default: 0]
    }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let key: Element
        if let keyIndex = storage.keys.firstIndex(of: newMember) {
            key = storage.keys[keyIndex]
        } else {
            key = newMember
        }
        let count = storage[key, default: 0] + 1
        storage[key] = count
        return (true, key)
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        guard let keyIndex = storage.keys.firstIndex(of: member) else {
            return nil
        }
        let key = storage.keys[keyIndex]
        let count = storage[key, default: 1] - 1
        if count <= 0 {
            storage[key] = nil
        } else {
            storage[key] = count
        }
        return key
    }
}

extension CountedSet: Sequence {
    
    public var underestimatedCount: Int { storage.count }
    
    public func makeIterator() -> Iterator {
        return Iterator(set: self)
    }
    
    public struct Iterator: IteratorProtocol {
        
        private let set: CountedSet<Element>
        private var current: Index
        
        internal init(set: CountedSet<Element>) {
            self.set = set
            self.current = set.startIndex
        }
        
        public mutating func next() -> Element? {
            guard current < set.endIndex else {
                return nil
            }
            
            let element = set[current]
            current = set.index(after: current)
            return element
        }
        
    }
}

extension CountedSet: Equatable, Hashable {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.storage == rhs.storage
    }
    
}

extension CountedSet: Collection {
    
    public struct Index: Comparable {
        
        public static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.key < rhs.key { return true }
            if lhs.key > rhs.key { return false }
            return lhs.offset < rhs.offset
        }
        
        internal let key: Storage.Index
        internal let offset: Int
    }
    
    public var startIndex: Index {
        return Index(key: storage.startIndex, offset: 0)
    }
    
    public var endIndex: Index {
        return Index(key: storage.endIndex, offset: 0)
    }
    
    public subscript(position: Index) -> Element {
        let (item, count) = storage[position.key]
        guard position.offset >= 0 && position.offset < count else {
            fatalError("Invalid offset in key \(position)")
        }
        return item
    }
    
    public func index(after i: Index) -> Index {
        let (_, count) = storage[i.key]
        let proposedOffset = i.offset + 1
        if proposedOffset < count {
            return Index(key: i.key, offset: proposedOffset)
        } else {
            let after = storage.index(after: i.key)
            return Index(key: after, offset: 0)
        }
    }
    
}

extension CountedSet: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        self.init()
        for item in elements {
            self.insert(item)
        }
    }
    
}

extension CountedSet: SetAlgebra {
    
    public func union(_ other: Self) -> Self {
        var newStorage = self.storage
        for (key, count) in other.storage {
            newStorage[key, default: 0] += count
        }
        return CountedSet(storage: newStorage)
    }
    
    public func intersection(_ other: Self) -> Self {
        var newStorage = Storage()
        for (key, count) in self.storage {
            let otherCount = other.count(for: key)
            if otherCount > 0 {
                newStorage[key] = Swift.min(count, otherCount)
            }
        }
        return CountedSet(storage: newStorage)
    }
    
    public func symmetricDifference(_ other: Self) -> Self {
        var newStorage = Storage()
        
        for (key, count) in self.storage {
            let otherCount = other.count(for: key)
            let remainingCount = count - otherCount
            if remainingCount > 0 {
                newStorage[key] = remainingCount
            }
        }
        
        for (key, count) in other.storage {
            let thisCount = self.count(for: key)
            let remainingCount = count - thisCount
            if remainingCount > 0 {
                newStorage[key] = remainingCount
            }
        }
        
        return CountedSet(storage: newStorage)
    }
    
    public func subtracting(_ other: Self) -> Self {
        var newStorage = self.storage
        for (item, count) in other.storage {
            guard let thisCount = newStorage[item] else { continue }
            if thisCount <= count {
                newStorage.removeValue(forKey: item)
            } else {
                newStorage[item] = thisCount - count
            }
        }
        return CountedSet(storage: newStorage)
    }
    
    public mutating func update(with newMember: Self.Element) -> Self.Element? {
        guard let index = storage.firstIndex(where: { $0.key == newMember }) else {
            return nil
        }
        let (existing, count) = storage.remove(at: index)
        storage[newMember] = count
        return existing
    }
    
    public mutating func formUnion(_ other: Self) {
        self = self.union(other)
    }
    
    public mutating func formIntersection(_ other: Self) {
        self = self.intersection(other)
    }
    
    public mutating func formSymmetricDifference(_ other: Self) {
        self = self.symmetricDifference(other)
    }
    
    public mutating func subtract(_ other: Self) {
        self = self.subtracting(other)
    }
    
    public func isDisjoint(with other: Self) -> Bool {
        for (item, _) in self.storage {
            guard other.count(for: item) == 0 else { return false }
        }
        return true
    }
    
    public func isSubset(of other: Self) -> Bool {
        for (item, count) in self.storage {
            let otherCount = other.count(for: item)
            guard otherCount >= count else { return false }
        }
        return true
    }
    
    public func isSuperset(of other: Self) -> Bool {
        for (item, count) in other.storage {
            let myCount = self.count(for: item)
            guard myCount >= count else { return false }
        }
        return true
    }
    
    public func isStrictSubset(of other: Self) -> Bool {
        // "Self" is a strict subset of "Other" if every member of "Self" is also a member of "Other" and
        // "Other" contains at least one element that is not a member of "Self".
        return other.isStrictSuperset(of: self)
    }
    
    public func isStrictSuperset(of other: Self) -> Bool {
        // if other has more keys, then other has more objects
        // and self CANNOT be a strict superset of other
        if other.storage.keys.count > self.storage.keys.count { return false }
        
        // "Self" is a strict superset of "Other" if every member of "Other" is also a member of "Self" and
        // "Self" contains at least one element that is not a member of "Other".
        for (item, count) in other.storage {
            let myCount = self.count(for: item)
            guard myCount > count else { return false }
        }
        return true
    }
}
