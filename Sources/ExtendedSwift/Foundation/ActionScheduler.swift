//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/21/23.
//

import Foundation

public class ActionScheduler<C: Clock>: @unchecked Sendable {
    
    public struct Token {
        let time: C.Instant
        let id: UUID
    }
    
    private struct Action { 
        let id: UUID
        let task: () async -> Void
    }
    
    private let clock: C
    private let tolerance: C.Duration
    private let lock: NSLock
    
    // may only be accessed from inside the lock
    private var scheduledActions = Dictionary<C.Instant, [Action]>()
    private var nextActionTime: C.Instant?
    private var timer: Task<Void, Error>?
    
    public init(clock: C, tolerance: C.Duration) {
        self.lock = NSLock()
        self.tolerance = tolerance
        self.clock = clock
    }
    
    @discardableResult
    public func scheduleAction(after duration: C.Duration, action: @escaping () -> Void) -> Token {
        let time = clock.now.advanced(by: duration)
        return self.scheduleAction(for: time, action: action)
    }
    
    @discardableResult
    public func scheduleAction(after duration: C.Duration, action: @escaping () async -> Void) -> Token {
        let time = clock.now.advanced(by: duration)
        return self.scheduleAction(for: time, action: action)
    }
    
    @discardableResult
    public func scheduleAction(for time: C.Instant, action: @escaping () -> Void) -> Token {
        let action = Action(id: UUID(), task: { action() })
        return self.schedule(action, for: time)
    }
    
    @discardableResult
    public func scheduleAction(for time: C.Instant, action: @escaping () async -> Void) -> Token {
        let action = Action(id: UUID(), task: action)
        return self.schedule(action, for: time)
    }
    
    private func schedule(_ action: Action, for time: C.Instant) -> Token {
        let token = Token(time: time, id: action.id)
        
        self.modifyActions { actions in
            actions[time, default: []].append(action)
        }
        
        return token
    }
    
    public func unscheduleAllActions() {
        self.modifyActions(using: { actions in
            actions.removeAll()
        })
    }
    
    public func unscheduleAction(_ token: Token) {
        self.modifyActions { actions in
            let actionsForThisTime = actions.removeValue(forKey: token.time)
            let stillScheduled = actionsForThisTime?.filter { $0.id != token.id }
            if stillScheduled?.isEmpty == false {
                actions[token.time] = stillScheduled
            }
        }
    }
    
    private func fire() {
        let now = self.clock.now
        
        let actionsToExecute = self.modifyActions { allActions in
            var remainingActions = Dictionary<C.Instant, [Action]>()
            var actionsToExecute = Array<Action>()
            for time in allActions.keys.sorted(by: <) {
                let actions = allActions[time] ?? []
                if time <= now {
                    actionsToExecute.append(contentsOf: actions)
                } else {
                    remainingActions[time] = actions
                }
            }
            
            allActions = remainingActions
            return actionsToExecute
        }
        
        if actionsToExecute.isNotEmpty {
            Task { @MainActor in
                for action in actionsToExecute {
                    await action.task()
                }
            }
        }
    }
    
    private func modifyActions<T>(using block: (inout Dictionary<C.Instant, [Action]>) -> T) -> T {
        return lock.withLock {
            let result = block(&scheduledActions)
            
            if let nextFireTime = scheduledActions.keys.min() {
                var needsScheduling = true
                
                if let currentlyScheduledFireTime = self.nextActionTime, currentlyScheduledFireTime <= nextFireTime, timer != nil {
                    // we already have something scheduled, and it's the soonest possible time
                    needsScheduling = false
                }
                
                if needsScheduling == true {
                    // the new fire time is sooner than the currently scheduled time, if there is one
                    self.timer?.cancel()
                    self.nextActionTime = nextFireTime
                    
                    let clock = self.clock
                    let tolerance = self.tolerance
                    
                    self.timer = Task.detached(priority: .userInitiated) { [weak self] in
                        do {
                            try? await clock.sleep(until: nextFireTime, tolerance: tolerance)
                            try Task.checkCancellation()
                            DispatchQueue.main.async { [weak self] in self?.fire() }
                        } catch {
                            // ignore the error; the task was cancelled
                        }
                    }
                }
            } else {
                self.timer?.cancel()
                self.timer = nil
                self.nextActionTime = nil
            }
            
            return result
        }
    }
}

extension ActionScheduler where C == UserClock {
    
    public convenience init() {
        self.init(clock: UserClock(), tolerance: .milliseconds(10))
    }
    
}
