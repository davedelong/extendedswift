import Synchronization

internal final class LoaderChain: Sendable {
    
    static let shared = LoaderChain()
    
    private typealias State = [ObjectIdentifier: HTTPLoader]
    
    // BUG: this will retain loaders indefinitely
    private let lock: Mutex<State>
    
    private init() {
        lock = Mutex([:])
    }
    
    func nextLoader(for loader: HTTPLoader) -> HTTPLoader? {
        return lock.withLock { state in
            return state[loader.loaderID]
        }
    }
    
    func setNextLoader(_ next: HTTPLoader?, for loader: HTTPLoader) {
        lock.withLock { state in
            let id = loader.loaderID
            if let n = next {
                var seen = Set<ObjectIdentifier>()
                seen.insert(id)
                
                var current = id
                while let nextLoader = state[current] {
                    let nextID = nextLoader.loaderID
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
