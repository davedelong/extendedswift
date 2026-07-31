//
//  QueueBasedActor.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 7/6/26.
//

import Foundation
import Dispatch
private import Synchronization

public protocol QueueBasedActor: Actor {
    nonisolated var queue: DispatchSerialQueue { get }
    nonisolated var operationQueue: OperationQueue { get }
}

extension QueueBasedActor {
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        queue.asUnownedSerialExecutor()
    }
    
    public nonisolated var operationQueue: OperationQueue {
        let id = ObjectIdentifier(self)
        return queues.withLock { known in
            if let existing = known[id] { return existing }
            
            let new = OperationQueue()
            new.name = "\(self.queue.label)-OperationQueue"
            new.underlyingQueue = self.queue
            known[id] = new
            return new
        }
    }
    
}

public protocol QueueBasedGlobalActor: GlobalActor {
    static var sharedQueue: DispatchSerialQueue { get }
    static var sharedOperationQueue: OperationQueue { get }
}

extension QueueBasedGlobalActor {
    
    public static var sharedUnownedExecutor: UnownedSerialExecutor {
        sharedQueue.asUnownedSerialExecutor()
    }
    
    public static nonisolated var sharedOperationQueue: OperationQueue {
        let id = ObjectIdentifier(self)
        return queues.withLock { known in
            if let existing = known[id] { return existing }
            
            let new = OperationQueue()
            new.name = "\(self.sharedQueue.label)-OperationQueue"
            new.underlyingQueue = self.sharedQueue
            known[id] = new
            return new
        }
    }
    
}

// MARK: - OperationQueues

private let queues = Mutex<Dictionary<ObjectIdentifier, OperationQueue>>([:])
