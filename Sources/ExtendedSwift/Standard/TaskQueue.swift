//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

public actor TaskQueue {
    private let target: TaskQueue?
    private var maximumNumberOfTasks: Int
    
    private var ongoingCount = 0
    public var hasOngoingTasks: Bool { ongoingCount > 0 }
    
    private var pending = Array<CheckedContinuation<Void, Never>>()
    
    public init(capacity: Int = Int.max, target: TaskQueue? = nil) {
        self.maximumNumberOfTasks = capacity
        self.target = target
    }
    
    @discardableResult
    public nonisolated func enqueue(name: String, priority: TaskPriority? = nil, _ task: @Sendable @escaping () async -> Void) -> Task<Void, Never> {
        return Task.detached(priority: priority, operation: {
            await self.waitForCapacity()
            if let t = self.target {
                let targetTask = t.enqueue(name: name, priority: priority, task)
                _ = await targetTask.result
            } else {
                if Task.isCancelled == false {
                    await task()
                }
            }
            await self.signalAvailableCapacity()
        })
    }
    
    private func waitForCapacity() async {
        if ongoingCount >= maximumNumberOfTasks {
            await withCheckedContinuation { pending.append($0) }
        }
        
        self.ongoingCount += 1
    }
    
    private func signalAvailableCapacity() {
        self.ongoingCount -= 1
        
        let availableCapacity = maximumNumberOfTasks - ongoingCount
        if availableCapacity > 0 {
            let numberToSignal = min(availableCapacity, pending.count)
            let continuations = pending.prefix(numberToSignal)
            pending.removeFirst(numberToSignal)
                
            continuations.forEach { $0.resume() }
        }
    }
    
}
