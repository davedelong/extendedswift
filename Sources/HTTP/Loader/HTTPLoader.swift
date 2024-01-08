public protocol HTTPLoader: Actor {
    
    func load(request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult
    
}

extension HTTPLoader {
    
    public nonisolated var nextLoader: HTTPLoader? {
        get  { LoaderChain.shared.nextLoader(for: self) }
        set { LoaderChain.shared.setNextLoader(newValue, for: self) }
    }
    
    public func withNextLoader(for request: HTTPRequest, perform: (HTTPLoader) async -> HTTPResult) async -> HTTPResult {
        guard let next = nextLoader else {
            let error = HTTPError(code: .cannotConnect,
                                  request: request,
                                  message: "\(type(of: self)) does not have a nextLoader")
            return .failure(error)
        }
        
        return await perform(next)
    }
    
    public func load(request: HTTPRequest) async -> HTTPResult {
        let token = HTTPRequestToken()
        return await load(request: request, token: token)
    }
    
}

precedencegroup HTTPLoaderChainingPrecedence {
    higherThan: NilCoalescingPrecedence
    associativity: right
}

infix operator --> : HTTPLoaderChainingPrecedence

@discardableResult
public func --> (lhs: HTTPLoader?, rhs: HTTPLoader) async -> HTTPLoader {
    lhs?.nextLoader = rhs
    return lhs ?? rhs
}

@discardableResult
public func --> (lhs: HTTPLoader?, rhs: HTTPLoader?) async -> HTTPLoader? {
    lhs?.nextLoader = rhs
    return lhs ?? rhs
}
