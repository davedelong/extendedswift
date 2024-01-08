public typealias HTTPResult = Result<HTTPResponse, HTTPError>

extension HTTPResult {
    
    public var request: HTTPRequest {
        switch self {
        case .success(let response): return response.request
        case .failure(let error): return error.request
        }
    }
    
    public var response: HTTPResponse? {
        switch self {
        case .success(let response): return response
        case .failure(let error): return error.response
        }
    }
    
    public init(request: HTTPRequest, catching responseProducer: () throws -> HTTPResponse) {
        do {
            let response = try responseProducer()
            self = .success(response)
        } catch {
            let error = HTTPError(error: error, request: request)
            self = .failure(error)
        }
    }
    
    public func apply(request: HTTPRequest) -> HTTPResult {
        switch self {
            case .failure(let error):
                let remade = HTTPError(code: error.code,
                                       request: request,
                                       response: error.response,
                                       message: error.message,
                                       underlyingError: error.underlyingError)
                return .failure(remade)
                
            case .success(let response):
                let remade = HTTPResponse(request: request,
                                          status: response.status,
                                          headers: response.headers,
                                          body: response.body)
                return .success(remade)
        }
    }
    
    public func modifyResponse(_ modify: (inout HTTPResponse) -> Void) -> HTTPResult {
        switch self {
            case .failure(let error):
                if var response = error.response {
                    modify(&response)
                    let newError = HTTPError(code: error.code,
                                             request: error.request,
                                             response: response,
                                             message: error.message,
                                             underlyingError: error.underlyingError)
                    return .failure(newError)
                } else {
                    return .failure(error)
                }
            case .success(var response):
                modify(&response)
                return .success(response)
        }
    }
    
}
