//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

public struct Scanner<C: Collection> {
    
    public enum ScannerError: Error {
        case isAtEnd
        case invalidElement(C.Element)
        case invalidSequence(C.SubSequence)
    }
    
    public typealias Element = C.Element
    
    public let data: C
    public var location: C.Index {
        willSet {
            guard newValue >= data.startIndex && newValue <= data.endIndex else {
                fatalError("Setting the location to an invalid index is a programmer error")
            }
        }
    }
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
    public mutating func scanElement(where predicate: (Element) -> Bool) throws -> Element {
        let start = location
        let next = try scanElement()
        if predicate(next) { return next }
        location = start
        throw ScannerError.invalidElement(next)
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
    public mutating func scan(count: Int) throws -> C.SubSequence {
        let start = location
        guard let end = data.index(location, offsetBy: count, limitedBy: data.endIndex) else {
            throw ScannerError.isAtEnd
        }
        location = end
        return data[start ..< location]
    }
    
    @discardableResult
    public mutating func scan(count: Int, where matches: (Element) -> Bool) throws -> C.SubSequence {
        let start = location
        do {
            for _ in 0 ..< count { _ = try scanElement(where: matches) }
            return data[start ..< location]
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scan(_ other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> Bool {
        let start = location
        do {
            for element in other {
                let next = try scanElement()
                guard predicate(next, element) else {
                    location = start
                    throw ScannerError.invalidElement(next)
                }
            }
            return true
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scan(upTo element: Element, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        let start = location
        do {
            while isAtEnd == false {
                let beforeThisElement = location
                let next = try scanElement()
                if predicate(next, element) == true {
                    location = beforeThisElement
                    return data[start ..< beforeThisElement]
                }
            }
            throw ScannerError.isAtEnd
        } catch {
            location = start
            throw error
        }
    }
    
    @discardableResult
    public mutating func scan(upTo other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        if other.isEmpty { return data[location ..< location] }
        
        let startLocation = location
        let startOfOther = other.first!
        
        do {
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
            throw ScannerError.isAtEnd
        } catch {
            location = startLocation
            throw error
        }
    }
    
    @discardableResult
    public mutating func scan(until element: Element, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        let start = self.location
        try self.scan(upTo: element, using: predicate)
        try self.scanElement(where: { predicate($0, element) })
        return data[start ..< self.location]
    }
    
    @discardableResult
    public mutating func scan(until other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        let start = self.location
        try self.scan(upTo: other, using: predicate)
        try self.scan(other, using: predicate)
        return data[start ..< self.location]
    }
}

extension Scanner where Element: Equatable {
    
    @discardableResult
    public mutating func scanElement(_ element: Element) throws -> Element {
        try self.scanElement(where: { $0 == element })
    }
    
    @discardableResult
    public mutating func scanElement(in other: some Collection<Element>) throws -> Element {
        try scanElement(where: { other.contains($0) })
    }
    
    @discardableResult
    public mutating func scan(anyFrom other: some Collection<Element>) throws -> C.SubSequence {
        try scan(while: { other.contains($0) })
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
    
    @discardableResult
    public mutating func scan(until element: Element) throws -> C.SubSequence {
        try self.scan(until: element, using: ==)
    }
    
    @discardableResult
    public mutating func scan(until other: some Collection<Element>) throws -> C.SubSequence {
        try self.scan(until: other, using: ==)
    }
    
}
