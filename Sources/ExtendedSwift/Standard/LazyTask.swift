//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/2/23.
//

import Foundation

public actor LazyTask<Success, Failure> where Success: Sendable, Failure: Error {
    
    private enum State {
        case waiting
        case task(Task<Success, Failure>)
        case cancelled
    }
    
    private let generator: () -> Task<Success, Failure>
    private var state: State
    
    public var value: Success {
        get async throws {
            if case .waiting = state {
                let task = generator()
                self.state = .task(task)
                return try await task.value
            } else if case .task(let task) = state {
                return try await task.value
            } else {
                throw CancellationError()
            }
        }
    }
    
    public init(priority: TaskPriority? = nil, _ promise: @escaping @Sendable () async -> Success) where Failure == Never {
        self.state = .waiting
        self.generator = {
            return Task(priority: priority, operation: promise)
        }
    }
    
    public func cancel() {
        if case .task(let t) = state {
            self.state = .cancelled
            t.cancel()
        } else {
            self.state = .cancelled
        }
    }
    
    public func reset() {
        self.state = .waiting
    }
}
