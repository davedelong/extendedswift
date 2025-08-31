//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension SetAlgebra {
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.union(rhs)
    }
    
    public static func + (lhs: Self, rhs: some Collection<Element>) -> Self {
        return lhs.union(rhs)
    }
    
    public static func + (lhs: Self, rhs: Element) -> Self {
        return lhs.union([rhs])
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        return lhs.subtracting(rhs)
    }
    
    public static func - (lhs: Self, rhs: some Collection<Element>) -> Self {
        return lhs.subtracting(rhs)
    }
    
    public static func - (lhs: Self, rhs: Element) -> Self {
        return lhs.subtracting([rhs])
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.formUnion(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: some Collection<Element>) {
        lhs.formUnion(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: some Collection<Element>) {
        lhs.subtract(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: Element) {
        lhs.remove(rhs)
    }
    
    public subscript(contains element: Element) -> Bool {
        get { return self.contains(element) }
        set {
            if newValue {
                self.insert(element)
            } else {
                self.remove(element)
            }
        }
    }
    
    @discardableResult
    public mutating func toggle(_ element: Element) -> Bool {
        if contains(element) {
            remove(element)
            return false
        } else {
            insert(element)
            return true
        }
    }
    
    public func contains(all: some Sequence<Element>) -> Bool {
        for item in all {
            if contains(item) == false { return false }
        }
        return true
    }
    
    public func contains(any: some Sequence<Element>) -> Bool {
        for item in any {
            if contains(item) { return true }
        }
        return false
    }
    
    public func intersects(_ other: Self) -> Bool {
        let i = self.intersection(other)
        return i.isEmpty == false
    }
    
    @_disfavoredOverload
    public func intersects(_ other: some Collection<Element>) -> Bool {
        for item in other {
            if contains(item) { return true }
        }
        return false
    }
    
    @_disfavoredOverload
    public func intersection(_ other: some Collection<Element>) -> Self {
        var result = Self()
        for item in other {
            if contains(item) { result.insert(item) }
        }
        return result
    }
    
    @_disfavoredOverload
    public mutating func formIntersection(_ other: some Collection<Element>) {
        self = self.intersection(other)
    }
    
    @_disfavoredOverload
    public func symmetricDifference(_ other: some Collection<Element>) -> Self {
        var result = self
        result.formUnion(other)
        for item in other {
            if contains(item) { result.remove(item) }
        }
        return result
    }
    
    @_disfavoredOverload
    public mutating func formSymmetricDifference(_ other: some Collection<Element>) {
        self = self.symmetricDifference(other)
    }
    
    @_disfavoredOverload
    public func union(_ other: some Collection<Element>) -> Self {
        var copy = self
        copy.formUnion(other)
        return copy
    }
    
    @_disfavoredOverload
    public mutating func formUnion(_ other: some Collection<Element>) {
        for item in other {
            insert(item)
        }
    }
    
    @_disfavoredOverload
    public func subtracting(_ other: some Collection<Element>) -> Self {
        var copy = self
        copy.subtract(other)
        return copy
    }
    
    @_disfavoredOverload
    public mutating func subtract(_ other: some Collection<Element>) {
        for item in other {
            remove(item)
        }
    }
    
    @_disfavoredOverload
    public func isDisjoint(with other: some Collection<Element>) -> Bool {
        return self.intersects(other) == false
    }
    
    @_disfavoredOverload
    public func isSubset(of other: some Collection<Element>) -> Bool {
        if isEmpty { return true }
        
        // this is a subset of that if we can remove every in that from this, and end up empty
        var temp = self
        for item in other {
            temp.remove(item)
        }
        return temp.isEmpty
    }
    
    @_disfavoredOverload
    public func isSuperset(of other: some Collection<Element>) -> Bool {
        // this is a superset of that if we contain everything other
        for item in other {
            if contains(item) == false { return false }
        }
        return true
    }
    
    @_disfavoredOverload
    public func isStrictSubset(of other: some Collection<Element>) -> Bool {
        var temp = self
        var uncontainedCount = 0
        for item in other {
            if contains(item) == false { uncontainedCount += 1 }
            temp.remove(item)
        }
        return uncontainedCount > 0
    }
    
    @_disfavoredOverload
    public func isStrictSuperset(of other: some Collection<Element>) -> Bool {
        var temp = self
        for item in other {
            if contains(item) == false { return false }
            temp.remove(item)
        }
        return temp.isEmpty == false
    }
}

extension Set where Element: BinaryInteger {
    
    public var bitmask: Element {
        var base = Element.zero
        for item in self {
            base |= item
        }
        return base
    }
    
}

extension Set where Element: RawRepresentable, Element.RawValue: BinaryInteger {
    
    public var bitmask: Element.RawValue {
        var base = Element.RawValue.zero
        for item in self {
            base |= item.rawValue
        }
        return base
    }
    
}
