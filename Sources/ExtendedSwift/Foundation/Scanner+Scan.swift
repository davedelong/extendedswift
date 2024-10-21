//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/20/24.
//

import Foundation

extension Scanner {
    
    @discardableResult
    public mutating func scanElement() throws -> Element {
        if isAtEnd { throw ScannerError.isAtEnd }
        
        let element = data[location]
        location = data.index(after: location)
        return element
    }
    
    @_disfavoredOverload
    public mutating func scanElement() -> Bool {
        return (try? self.scanElement()) != nil
    }
    
    @discardableResult
    public mutating func scanElement(where predicate: (Element) -> Bool) throws -> Element {
        let start = location
        let next = try scanElement()
        if predicate(next) { return next }
        location = start
        throw ScannerError.invalidElement(next)
    }
    
    @_disfavoredOverload
    public mutating func scanElement(where predicate: (Element) -> Bool) -> Bool {
        return (try? self.scanElement(where: predicate)) != nil
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
    
    @_disfavoredOverload
    public mutating func scan(while matches: (Element) -> Bool) -> Bool {
        return (try? self.scan(while: matches)) != nil
    }
    
    @discardableResult
    public mutating func scan(count: Int) throws -> C.SubSequence {
        if count <= 0 { return data[location ..< location] }
        
        let start = location
        location = try data.index(location, offsetBy: count, limitedBy: data.endIndex) ?! ScannerError.isAtEnd
        return data[start ..< location]
    }
    
    @_disfavoredOverload
    public mutating func scan(count: Int) -> Bool {
        return (try? self.scan(count: count)) != nil
    }
    
    @discardableResult
    public mutating func scan(count: Int, where matches: (Element) -> Bool) throws -> C.SubSequence {
        if count <= 0 { return data[location ..< location] }
        
        let start = location
        do {
            for _ in 0 ..< count { _ = try scanElement(where: matches) }
            return data[start ..< location]
        } catch {
            location = start
            throw error
        }
    }
    
    @_disfavoredOverload
    public mutating func scan(count: Int, where matches: (Element) -> Bool) -> Bool {
        return (try? self.scan(count: count, where: matches)) != nil
    }
    
    @discardableResult
    public mutating func scan(_ other: some Collection<Element>, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        if other.count <= 0 { return data[location ..< location] }
        
        let start = location
        do {
            for element in other {
                let next = try scanElement()
                guard predicate(next, element) else {
                    throw ScannerError.invalidElement(next)
                }
            }
            return data[start ..< location]
        } catch {
            location = start
            throw error
        }
    }
    
    @_disfavoredOverload
    public mutating func scan(_ other: some Collection<Element>, using predicate: (Element, Element) -> Bool) -> Bool {
        return (try? self.scan(other, using: predicate)) != nil
    }
    
    @discardableResult
    public mutating func scan(upTo element: Element, including: Bool = false, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        let start = location
        do {
            while isAtEnd == false {
                let beforeThisElement = location
                let next = try scanElement()
                if predicate(next, element) == true {
                    if including == false {
                        // don't include the trailing element in the result
                        location = beforeThisElement
                    }
                    return data[start ..< beforeThisElement]
                }
            }
            throw ScannerError.isAtEnd
        } catch {
            location = start
            throw error
        }
    }
    
    @_disfavoredOverload
    public mutating func scan(upTo element: Element, including: Bool = false, using predicate: (Element, Element) -> Bool) -> Bool {
        return (try? self.scan(upTo: element, including: including, using: predicate)) != nil
    }
    
    @discardableResult
    public mutating func scan(upTo other: some Collection<Element>, including: Bool = false, using predicate: (Element, Element) -> Bool) throws -> C.SubSequence {
        if other.isEmpty { return data[location ..< location] }
        
        let startLocation = location
        let startOfOther = other.first!
        
        do {
            while isAtEnd == false {
                try self.scan(upTo: startOfOther, using: predicate)
                let potentialStart = location
                if let _ = try? self.scan(other, using: predicate) {
                    // the collection follows
                    if including == false {
                        // don't include the trailing collection in the result
                        location = potentialStart
                    }
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
    
    @_disfavoredOverload
    public mutating func scan(upTo other: some Collection<Element>, including: Bool = false, using predicate: (Element, Element) -> Bool) -> Bool {
        return (try? self.scan(upTo: other, including: including, using: predicate)) != nil
    }
    
}

extension Scanner where Element: Equatable {
    
    @discardableResult
    public mutating func scanElement(_ element: Element) throws -> Element {
        try self.scanElement(where: { $0 == element })
    }
    
    @_disfavoredOverload
    public mutating func scanElement(_ element: Element) -> Bool {
        return (try? self.scanElement(element)) != nil
    }
    
    @discardableResult
    public mutating func scanElement(in other: some Collection<Element>) throws -> Element {
        try scanElement(where: { other.contains($0) })
    }
    
    @_disfavoredOverload
    public mutating func scanElement(in other: some Collection<Element>) -> Bool {
        return (try? self.scanElement(in: other)) != nil
    }
    
    @discardableResult
    public mutating func scan(anyFrom other: some Collection<Element>) throws -> C.SubSequence {
        try scan(while: { other.contains($0) })
    }
    
    @_disfavoredOverload
    public mutating func scan(anyFrom other: some Collection<Element>) -> Bool {
        return (try? self.scan(anyFrom: other)) != nil
    }
    
    @discardableResult
    public mutating func scan(_ other: some Collection<Element>) throws -> C.SubSequence {
        try self.scan(other, using: ==)
    }
    
    @_disfavoredOverload
    public mutating func scan(_ other: some Collection<Element>) -> Bool {
        return (try? self.scan(other)) != nil
    }
    
    @discardableResult
    public mutating func scan(upTo element: Element, including: Bool = false) throws -> C.SubSequence {
        try self.scan(upTo: element, including: including, using: ==)
    }
    
    @_disfavoredOverload
    public mutating func scan(upTo element: Element, including: Bool = false) -> Bool {
        return (try? self.scan(upTo: element, including: including, using: ==)) != nil
    }
    
    @discardableResult
    public mutating func scan(upTo other: some Collection<Element>, including: Bool = false) throws -> C.SubSequence {
        try self.scan(upTo: other, including: including, using: ==)
    }
    
    @_disfavoredOverload
    public mutating func scan(upTo other: some Collection<Element>, including: Bool = false) -> Bool {
        return (try? self.scan(scan(upTo: other, including: including, using: ==))) != nil
    }
    
}
