//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension SetAlgebra {
    
    public static func += (lhs: inout Self, rhs: Element) { lhs.insert(rhs) }
    
    public var isNotEmpty: Bool {
        return self.isEmpty == false
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
        return i.isNotEmpty
    }
    
}
