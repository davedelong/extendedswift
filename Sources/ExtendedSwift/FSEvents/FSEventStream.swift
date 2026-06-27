//
//  FSEventStream.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 6/27/26.
//


import Foundation

#if os(macOS)

public struct FSEventStream: AsyncSequence {
    
    private let path: Path
    
    public init(path: Path) {
        self.path = path
    }
    
    public func makeAsyncIterator() -> some AsyncIteratorProtocol {
        return AsyncStream(FSEvent.self, bufferingPolicy: .unbounded) { continuation in
            let watcher = FSWatcher(path: path, report: {
                continuation.yield($0)
            })
            continuation.onTermination = { arg in
                watcher.cancel()
            }
        }
        .makeAsyncIterator()
    }
    
}

#endif
