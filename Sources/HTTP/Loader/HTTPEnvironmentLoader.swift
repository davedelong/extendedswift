import Foundation

public struct HTTPRequestEnvironment: Sendable, HTTPOption {
    
    public static let defaultValue: HTTPRequestEnvironment? = nil
    
    public var method: HTTPMethod?
    
    public var host: String?
    
    public var pathPrefix: String
    
    public var query: HTTPQuery?
    
    public var headers: HTTPHeaders?
    
    public init(method: HTTPMethod? = nil, host: String? = nil, pathPrefix: String = "/", query: HTTPQuery? = nil, headers: HTTPHeaders? = nil) {
        
        let prefix = pathPrefix.hasPrefix("/") ? "" : "/"
        
        self.method = method
        self.host = host
        self.pathPrefix = prefix + pathPrefix
        self.query = query
        self.headers = headers
    }
    
    fileprivate func apply(to request: inout HTTPRequest) {
        if let method {
            request.method = method
        }
        
        if let host, request.host == nil {
            request.host = host
        }
        
        let requestPath = request.path ?? ""
        if requestPath.isEmpty {
            request.path = pathPrefix
        } else if requestPath.hasPrefix("/") == false {
            if pathPrefix.hasSuffix("/") == false {
                request.path = pathPrefix + "/" + requestPath
            } else {
                request.path = pathPrefix + requestPath
            }
        }
        
        if let query {
            for (name, value) in query {
                request.query.addValue(value, for: name)
            }
        }
        
        if let headers {
            for (header, value) in headers {
                request.headers.addValue(value, for: header)
            }
        }
    }
    
}

public actor HTTPEnvironmentLoader: HTTPLoader {
    
    public let environment: HTTPRequestEnvironment
    
    public init(environment: HTTPRequestEnvironment) {
        self.environment = environment
    }
    
    public func load(request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        return await withNextLoader(for: request) { next in
            var copy = request
            let environment = request[option: HTTPRequestEnvironment.self] ?? self.environment
            environment.apply(to: &copy)
            return await next.load(request: copy, token: token)
        }
    }
    
}
