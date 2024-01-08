public protocol HTTPRedirectionHandler {
    
    func handleRedirection(for request: HTTPRequest, response: HTTPResponse, proposedRedirection: HTTPRequest) async -> HTTPRequest?
    
}

extension HTTPOptions {
    
    public var redirectionHandler: (any HTTPRedirectionHandler)? {
        get { self[HTTPRedirectonOption.self] }
        set { self[HTTPRedirectonOption.self] = newValue }
    }
    
}

private enum HTTPRedirectonOption: HTTPOption {
    static let defaultValue: (any HTTPRedirectionHandler)? = nil
}
