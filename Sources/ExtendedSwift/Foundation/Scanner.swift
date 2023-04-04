//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

public struct Scanner<C: RandomAccessCollection> {
    
    public enum ScannerError: Error {
        case isAtEnd
        case invalidElement(C.Element)
        case invalidSequence(C.SubSequence)
    }
    
    public typealias Element = C.Element
    
    public let data: C
    public var location: C.Index
    public var isAtEnd: Bool { location >= data.endIndex }
    
    public init(data: C) {
        self.data = data
        self.location = data.startIndex
    }
    
    @discardableResult
    public mutating func scanElement() throws -> Element {
        if isAtEnd { throw ScannerError.isAtEnd }
        
        let element = data[location]
        location = data.index(after: location)
        return element
    }
    
    @discardableResult
    public mutating func scan(while matches: (Element) -> Bool) throws -> C.SubSequence {
        if isAtEnd { throw ScannerError.isAtEnd }
        let start = location
        while isAtEnd == false && matches(data[location]) {
            location = data.index(after: location)
        }
        return data[start ..< location]
    }
    
    @discardableResult
    public mutating func scan(count: Int) -> C.SubSequence {
        let start = location
        location = data.index(location, offsetBy: count, limitedBy: data.endIndex) ?? data.endIndex
        return data[start ..< location]
    }
    
    // Scanning
    
    @discardableResult
    public mutating func scan(using predicate: (Element) -> Bool) throws -> Element {
        let start = location
        let next = try scanElement()
        if predicate(next) { return next }
        location = start
        throw ScannerError.invalidElement(next)
    }
    
    @discardableResult
    public mutating func scan(_ other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> Bool {
        let start = location
        for element in other {
            let next = try scanElement()
            guard predicate(next, element) else {
                location = start
                throw ScannerError.invalidElement(next)
            }
        }
        return true
    }
    
    @discardableResult
    public mutating func scan(upTo element: Element, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        let start = location
        while isAtEnd == false {
            let next = try scanElement()
            if predicate(next, element) == true {
                return data[start ..< location]
            }
        }
        location = start
        throw ScannerError.isAtEnd
    }
    
    @discardableResult
    public mutating func scan(upTo other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        if other.isEmpty { return data[location ..< location] }
        
        let startLocation = location
        let startOfOther = other.first!
        
        while isAtEnd == false {
            try self.scan(upTo: startOfOther, using: predicate)
            let potentialStart = location
            if let _ = try? self.scan(other, using: predicate) {
                // the collection follows
                location = potentialStart
                return data[startLocation ..< location]
            }
            try self.scanElement()
        }
        
        location = startLocation
        throw ScannerError.isAtEnd
    }
}

extension Scanner where Element: Equatable {
    
    // Scanning
    @discardableResult
    public mutating func scan(_ element: Element) throws -> Element {
        try self.scan(using: { $0 == element })
    }
    
    @discardableResult
    public mutating func scan(_ other: some Collection<Element>) throws -> Bool {
        try self.scan(other, using: ==)
    }
    
    @discardableResult
    public mutating func scan(upTo element: Element) throws -> C.SubSequence {
        try self.scan(upTo: element, using: ==)
    }
    
    @discardableResult
    public mutating func scan(upTo other: some Collection<Element>) throws -> C.SubSequence {
        try self.scan(upTo: other, using: ==)
    }
    
}
