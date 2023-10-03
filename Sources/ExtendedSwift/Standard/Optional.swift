//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation

extension Optional {
    
    public var unwrapped: Wrapped {
        return self !! "Cannot unwrap nil \(Self.self)"
    }
    
    public func apply(_ closure: (Wrapped) throws -> Void) rethrows {
        if let value = self {
            try closure(value)
        }
    }
}

extension Optional: Sequence where Wrapped: Sequence {
    public typealias Element = Wrapped.Element
    public typealias Iterator = OptionalIterator<Wrapped>
    
    public func makeIterator() -> OptionalIterator<Wrapped> {
        return OptionalIterator(inner: self?.makeIterator())
    }
    
}

public struct OptionalIterator<Wrapped: Sequence>: IteratorProtocol {
    var inner: Wrapped.Iterator?
    
    public mutating func next() -> Wrapped.Element? {
        return inner?.next()
    }
}
