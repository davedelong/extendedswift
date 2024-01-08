public actor ThrottledLoader: HTTPLoader {
    
    private var maximumNumberOfTasks: Int
    
    private var ongoingCount = 0
    private var pending = [UnsafeContinuation<Void, Never>]()
    
    public init(maximumNumberOfTasks: Int = Int.max) {
        self.maximumNumberOfTasks = max(maximumNumberOfTasks, 0)
    }
    
    public func setMaximumNumberOfTasks(_ count: Int) {
        self.maximumNumberOfTasks = max(count, 0)
        signalAvailableCapacity()
    }
    
    public func load(request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        if request[option: \.throttleBehavior] == .unthrottled {
            return await withNextLoader(for: request) { next in
                return await next.load(request: request, token: token)
            }
        }
        
        if maximumNumberOfTasks <= 0 {
            print("Received request \(request.id) but \(type(of: self)) is paused (maximumNumberOfTasks = 0)")
        }
        
        #warning("TODO: handle cancellation")
        await waitForCapacity()
        
        return await withNextLoader(for: request) { next in
            ongoingCount += 1
            let result = await next.load(request: request, token: token)
            ongoingCount -= 1
            signalAvailableCapacity()
            return result
        }
    }
    
    private func waitForCapacity() async {
        if ongoingCount < maximumNumberOfTasks {
            return
        }
        
        return await withUnsafeContinuation { continuation in
            pending.append(continuation)
        }
    }
    
    private func signalAvailableCapacity() {
        let availableCapacity = maximumNumberOfTasks - ongoingCount
        guard availableCapacity > 0 else {
            return
        }
        
        let numberToSignal = min(availableCapacity, pending.count)
        let continuations = pending.prefix(numberToSignal)
        pending.removeFirst(numberToSignal)
        
        continuations.forEach {
            $0.resume()
        }
    }
    
}
