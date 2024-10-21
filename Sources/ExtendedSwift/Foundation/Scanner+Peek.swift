//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/20/24.
//

import Foundation

extension Scanner {
    
    @discardableResult
    public func peekElement() -> Element? {
        var copy = self
        return try? copy.scanElement()
    }
    
    @discardableResult
    public func peekElement(where predicate: (Element) -> Bool) -> Element? {
        var copy = self
        return try? copy.scanElement(where: predicate)
    }
    
    @discardableResult
    public func peek(while matches: (Element) -> Bool) -> C.SubSequence {
        var copy = self
        return (try? copy.scan(while: matches)) ?? data[location ..< location]
    }
    
    @discardableResult
    public func peek(count: Int) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(count: count)
    }
    
    @discardableResult
    public func peek(count: Int, where matches: (Element) -> Bool) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(count: count, where: matches)
    }
    
    @discardableResult
    public func peek(_ other: some Collection<Element>, using predicate: (Element, Element) -> Bool) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(other, using: predicate)
    }
    
    @discardableResult
    public func peek(upTo element: Element, including: Bool = false, using predicate: (Element, Element) -> Bool) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(upTo: element, including: including, using: predicate)
    }
    
    @discardableResult
    public func peek(upTo other: some Collection<Element>, including: Bool = false, using predicate: (Element, Element) -> Bool) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(upTo: other, including: including, using: predicate)
    }
    
}

extension Scanner where Element: Equatable {
    
    @discardableResult
    public func peekElement(_ element: Element) -> Element? {
        var copy = self
        return try? copy.scanElement(element)
    }
    
    @discardableResult
    public func peekElement(in other: some Collection<Element>) -> Element? {
        var copy = self
        return try? copy.scanElement(in: other)
    }
    
    @discardableResult
    public func peek(anyFrom other: some Collection<Element>) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(anyFrom: other)
    }
    
    @discardableResult
    public func peek(_ other: some Collection<Element>) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(other)
    }
    
    @discardableResult
    public func peek(upTo element: Element, including: Bool = false) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(upTo: element, including: including, using: ==)
    }
    
    @discardableResult
    public func peek(upTo other: some Collection<Element>, including: Bool = false) -> C.SubSequence? {
        var copy = self
        return try? copy.scan(upTo: other, including: including, using: ==)
    }
    
}
