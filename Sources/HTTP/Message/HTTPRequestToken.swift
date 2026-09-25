import Synchronization

public class HTTPRequestToken: @unchecked Sendable {
    
    private typealias Handler = @Sendable () -> Void
    
    // The state of the token
    // - Array with 0-or-more elements = uncancelled
    // - nil = cancelled
    private typealias State = Array<Handler>?
    
    private let state = Mutex<State>([])
    
    public var isCancelled: Bool {
        return state.withLock { $0 == nil }
    }
    
    public init() { }
    
    public func cancel() {
        let handlersToExecute = state.withLock { state in
            let copy = state
            state = nil
            return copy ?? []
        }
        
        for handler in handlersToExecute.reversed() {
            handler()
        }
    }
    
    public func addCancellationHandler(_ handler: @escaping @Sendable () -> Void) {
        let handlerToExecute = state.withLock { state -> Handler? in
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
