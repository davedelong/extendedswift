//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/10/23.
//

import Foundation

@discardableResult
public func withExtendedLifetime<X, R>(_ x: X, _ body: () async throws -> R) async rethrows -> R {
    defer { _fixLifetime(x) }
    return try await body()
}

@discardableResult
public func withExtendedLifetime<X, R>(_ x: X, _ body: (X) async throws -> R) async rethrows -> R {
    defer { _fixLifetime(x) }
    return try await body(x)
}

extension AsyncSequence {
    
    public func eraseToAnySequence() -> AnyAsyncSequence<Element> {
        return AnyAsyncSequence(self)
    }
    
}

public struct AnyAsyncSequence<Element>: AsyncSequence {
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    private let getIterator: () -> AnyAsyncIterator<Element>
    
    public init<O: AsyncSequence>(_ other: O) where O.Element == Element {
        self.getIterator = {
            AnyAsyncIterator(other.makeAsyncIterator())
        }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        return getIterator()
    }
    
}

public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    
    private let getNext: () async throws -> Element?
    
    public init<O: AsyncIteratorProtocol>(_ other: O) where O.Element == Element {
        var copy = other
        self.getNext = { try await copy.next() }
    }
    
    public func next() async throws -> Element? {
        return try await getNext()
    }
    
}
