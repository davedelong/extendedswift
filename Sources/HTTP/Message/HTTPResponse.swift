public struct HTTPResponse: Sendable, CustomStringConvertible {
    
    public let request: HTTPRequest
    
    public var status: HTTPStatus
    
    public var headers = HTTPHeaders()
    
    public var body: (any HTTPBody)?
    
    public init(request: HTTPRequest,
                status: HTTPStatus,
                headers: HTTPHeaders = .init(),
                body: (any HTTPBody)? = nil) {
        
        self.request = request
        self.status = status
        self.headers = headers
        self.body = body
    }
    
    public subscript(header name: HTTPHeader) -> String? {
        get { headers.firstValue(for: name) }
        set { headers.setValue(newValue, for: name) }
    }
    
    public subscript(headers name: HTTPHeader) -> [String] {
        get { headers[name] }
        set { headers[name] = newValue }
    }
    
    public var description: String { descriptionLines.joined(separator: "\n") }
    
    public var descriptionLines: Array<String> {
        var lines = Array<String>()
        
        lines.append("\(status)")
        for (header, value) in headers {
            lines.append("\(header.rawValue): \(value)")
        }
        if let body {
            for (header, value) in body.headers {
                lines.append("\(header.rawValue): \(value)")
            }
            lines.append("")
            
            if let syncBody = body as? HTTPSynchronousBody, let data = try? syncBody.bodyData {
                if let str = String(data: data, encoding: .utf8) {
                    lines.append(str)
                } else {
                    lines.append(data.map { String(format: "%02X", $0) }.joined())
                }
            } else {
                lines.append("(omitted)")
            }
        }
        
        return lines
    }
    
}

extension HTTPResponse {
    
    public static func ok(_ request: HTTPRequest) -> HTTPResponse {
        return .init(request: request, status: .ok)
    }
    
}

#if canImport(Foundation)

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPResponse {
    
    public init(request: HTTPRequest, response: HTTPURLResponse, body: Data?) {
        var headers = HTTPHeaders()
        for (rawHeader, value) in response.allHeaderFields {
            let header = HTTPHeader(rawValue: rawHeader.description)
            let headerValue = (value as? String) ?? String(describing: value)
            
            headers.addValue(headerValue, for: header)
        }
        
        self.init(request: request,
                  status: HTTPStatus(rawValue: response.statusCode),
                  headers: headers,
                  body: body)
    }
    
}

#endif
