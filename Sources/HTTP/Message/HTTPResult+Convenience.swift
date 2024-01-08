import Foundation

extension HTTPResult {
    
    public static func failure(_ code: HTTPError.Code, request: HTTPRequest, response: HTTPResponse? = nil, underlyingError: Error? = nil) -> HTTPResult {
        let error = HTTPError(code: code, request: request, response: response, underlyingError: underlyingError)
        return .failure(error)
    }
    
    public static func ok(_ request: HTTPRequest) -> HTTPResult {
        let response = HTTPResponse(request: request, status: .ok)
        return .success(response)
    }
    
    public func ok<Body: Encodable>(_ request: HTTPRequest, json: Body) -> HTTPResult {
        return HTTPResult(request: request) {
            let body = try JSONEncoder().encode(json)
            var headers = HTTPHeaders()
            headers[.contentType] = ["application/json; charset=utf-8"]
            return HTTPResponse(request: self.request,
                                status: .ok,
                                headers: headers,
                                body: body)
        }
    }
    
    public static func internalServerError(_ request: HTTPRequest) -> HTTPResult {
        let response = HTTPResponse(request: request, status: .internalServerError)
        return .success(response)
    }
    
}
