public protocol HTTPRedirectionHandler: Sendable {
    
    func handleRedirection(for request: HTTPRequest, response: HTTPResponse, proposedRedirection: HTTPRequest) async -> HTTPRequest?
    
}

extension HTTPOptions {
    
    public var redirectionHandler: (any HTTPRedirectionHandler)? {
        get { self[HTTPRedirectonOption.self] }
        set { self[HTTPRedirectonOption.self] = newValue }
    }
    
}

// ERROR: Type 'any HTTPRedirectionHandler' does not conform to the 'Sendable' protocol
private enum HTTPRedirectonOption: HTTPOption {
    // ERROR: Static property 'defaultValue' is not concurrency-safe because
    // non-'Sendable' type '(any HTTPRedirectionHandler)?' may have shared mutable state
    static let defaultValue: (any HTTPRedirectionHandler)? = nil
}



