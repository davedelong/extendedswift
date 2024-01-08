import Foundation

extension HTTPRequest {
    
    internal init(request: URLRequest) {
        self.init()
        let components = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }
        
        if let m = request.httpMethod {
            self.method = HTTPMethod(rawValue: m)
        }
        self.host = components?.host
        self.path = components?.path
        self.fragment = components?.fragment
        
        for item in components?.queryItems ?? [] {
            self.query.addValue(item.value ?? "", for: item.name)
        }
        
        for (header, value) in request.allHTTPHeaderFields ?? [:] {
            self.headers.addValue(value, for: HTTPHeader(rawValue: header))
        }
    }
    
    internal func convertToURLRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        
        guard let host = host else {
            return nil
        }
        components.host = host
        components.path = path ?? ""
        components.fragment = fragment
        components.queryItems = query.map { name, value in
            return URLQueryItem(name: name, value: value.isEmpty ? nil : value)
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        for (header, value) in headers {
            urlRequest.addValue(value, forHTTPHeaderField: header.rawValue)
        }
        
        if let body = body {
            for (header, value) in body.headers {
                urlRequest.addValue(value, forHTTPHeaderField: header.rawValue)
            }
            
            if let syncBody = body as? HTTPSynchronousBody {
                do {
                    urlRequest.httpBody = try syncBody.bodyData
                } catch {
                    print("Error encoding body data: \(error)")
                    return nil
                }
            } else {
                fatalError("Async bodies are not supported yet")
            }
        }
        
        return urlRequest
    }
}
