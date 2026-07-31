//
//  FSEventStream.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 6/27/26.
//


import Foundation

#if os(macOS)

public struct FSEventStream: AsyncSequence {
    public typealias Element = FSEvent
    
    private let path: Path
    
    public init(path: Path) {
        self.path = path
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        let inner = AsyncStream(FSEvent.self, bufferingPolicy: .unbounded) { continuation in
            let watcher = FSWatcher(path: path, report: {
                continuation.yield($0)
            })
            continuation.onTermination = { arg in
                watcher.cancel()
            }
        }
        .makeAsyncIterator()
        
        return AsyncIterator(iterator: inner)
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        internal var iterator: AsyncStream<FSEvent>.AsyncIterator
        
        public mutating func next() async throws -> Element? {
            return await iterator.next()
        }
        
        public mutating func next(isolation actor: isolated (any Actor)?) async -> Element? {
            return await iterator.next(isolation: actor)
        }
    }
}

#endif
