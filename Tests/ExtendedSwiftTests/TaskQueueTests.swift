//
//  TaskQueueTests.swift
//  
//
//  Created by Dave DeLong on 6/3/23.
//

import XCTest
import ExtendedSwift

class TaskQueueTests: XCTestCase {
    
    func testNoLimit_SimpleExecute() async throws {
        let queue = TaskQueue()
        let t = queue.enqueue(name: "1", { 1 })
        let value = await t.value
        XCTAssertEqual(value, 1)
    }
    
    func testNoLimit_MultipleExecute() async throws {
        let queue = TaskQueue()
        let tasks = [
            queue.enqueue(name: "1", { 1 }),
            queue.enqueue(name: "2", { 2 }),
            queue.enqueue(name: "3", { 3 }),
        ]
        
        var values = Array<Int>()
        for task in tasks {
            values.append(await task.value)
        }
        XCTAssertEqual(values.count, 3)
        XCTAssertEqual(Set(values), [1, 2, 3]) // they can execute in any order
    }
    
    func testLimited_SimpleExecute() async throws {
        let queue = TaskQueue(capacity: 2)
        let t = queue.enqueue(name: "1", { 1 })
        let value = await t.value
        XCTAssertEqual(value, 1)
    }
    
    func testLimited_MultipleExecute() async throws {
        actor Counter {
            private(set) var maxOngoing = 0
            private var ongoing = 0 {
                didSet {
                    maxOngoing = max(maxOngoing, ongoing)
                }
            }
            
            func increment() { ongoing += 1 }
            func decrement() { ongoing -= 1 }
        }
        
        let queue = TaskQueue(capacity: 2)
        let counter = Counter()
        let tasks = [
            queue.enqueue(name: "1", {
                await counter.increment()
                try await Task.sleep(for: .milliseconds(3))
                await counter.decrement()
                return 1
            }),
            queue.enqueue(name: "2", {
                await counter.increment()
                try await Task.sleep(for: .milliseconds(5))
                await counter.decrement()
                return 2
            }),
            queue.enqueue(name: "3", {
                await counter.increment()
                try await Task.sleep(for: .milliseconds(4))
                await counter.decrement()
                return 3
            }),
        ]
        
        var values = Array<Int>()
        for task in tasks {
            values.append(try await task.value)
        }
        XCTAssertEqual(values.count, 3)
        XCTAssertEqual(Set(values), [1, 2, 3]) // they can execute in any order
        let maxOngoing = await counter.maxOngoing
        XCTAssertEqual(maxOngoing, 2)
    }
}
