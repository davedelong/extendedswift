import os

internal class LoaderChain {
    
    static let shared = LoaderChain()
    
    private typealias State = [ObjectIdentifier: HTTPLoader]
    
    // BUG: this will retain loaders indefinitely
    private var lock: OSAllocatedUnfairLock<State>
    
    private init() {
        lock = OSAllocatedUnfairLock(initialState: [:])
    }
    
    func nextLoader(for loader: HTTPLoader) -> HTTPLoader? {
        return lock.withLock { state in
            let id = ObjectIdentifier(loader)
            return state[id]
        }
    }
    
    func setNextLoader(_ next: HTTPLoader?, for loader: HTTPLoader) {
        lock.withLock { state in
            let id = ObjectIdentifier(loader)
            if let n = next {
                var seen = Set<ObjectIdentifier>()
                seen.insert(id)
                
                var current = id
                while let nextLoader = state[current] {
                    let nextID = ObjectIdentifier(nextLoader)
                    if seen.contains(nextID) {
                        fatalError("Cycle detected while setting the nextLoader")
                    } else {
                        seen.insert(nextID)
                        current = nextID
                    }
                }

                state[id] = n                
            } else {
                state.removeValue(forKey: id)
            }
        }
        
    }
    
}
