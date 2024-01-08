import os

public class HTTPRequestToken: @unchecked Sendable {
    
    private typealias Handler = () -> Void
    
    // The state of the token
    // - Array with 0-or-more elements = uncancelled
    // - nil = cancelled
    private typealias State = Array<Handler>?
    
    private var lock: OSAllocatedUnfairLock<State>
    
    public var isCancelled: Bool {
        return lock.withLock { $0 == nil }
    }
    
    public init() {
        lock = OSAllocatedUnfairLock(initialState: [])
    }
    
    public func cancel() {
        let handlersToExecute = lock.withLock { state in
            let copy = state
            state = nil
            return copy ?? []
        }
        
        for handler in handlersToExecute.reversed() {
            handler()
        }
    }
    
    public func addCancellationHandler(_ handler: @escaping () -> Void) {
        let handlerToExecute = lock.withLock { state -> Handler? in
            if state != nil {
                state?.append(handler)
                return nil
            } else {
                return handler
            }
        }
        
        handlerToExecute?()
    }
    
}
