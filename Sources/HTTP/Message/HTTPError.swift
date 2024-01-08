public struct HTTPError: Error, CustomStringConvertible {
    
    public enum Code {
        case cancelled
        case invalidRequest
        case cannotConnect
        case insecureConnection
        case cannotAuthenticate
        case timedOut
        case invalidResponse
        case cannotDecodeResponse
        case unknown
        case `internal`
    }
    
    public let code: Code
    public let request: HTTPRequest
    public let response: HTTPResponse?
    public let message: String?
    
    public let underlyingError: Error?
    
    public init(code: HTTPError.Code, request: HTTPRequest, response: HTTPResponse? = nil, message: String? = nil, underlyingError: Error? = nil) {
        self.code = code
        self.request = request
        self.response = response
        self.message = message
        self.underlyingError = underlyingError
    }
    
    public var description: String {
        var information = Array<String>()
        
        let codeInfo: String
        switch code {
            case .cancelled: codeInfo = "Cancelled"
            case .invalidRequest: codeInfo = "Invalid request"
            case .cannotConnect: codeInfo = "Cannot connect"
            case .insecureConnection: codeInfo = "Insecure connection"
            case .cannotAuthenticate: codeInfo = "Cannot authenticate"
            case .timedOut: codeInfo = "Timed out"
            case .invalidResponse: codeInfo = "Invalid response"
            case .cannotDecodeResponse: codeInfo = "Cannot decode response"
            case .unknown: codeInfo = "Unknown"
            case .internal: codeInfo = "Internal"
        }
        if let message {
            information.append("\(codeInfo): \(message)")
        } else {
            information.append(codeInfo)
        }
        
        information.append("REQUEST:")
        information.append(contentsOf: request.descriptionLines)
        
        if let response {
            information.append("")
            information.append("RESPONSE:")
            information.append(contentsOf: response.descriptionLines)
        }
        
        if let underlyingError {
            information.append("")
            information.append("UNDERLYING ERROR:")
            information.append("\(underlyingError)")
        }
        
        return information.joined(separator: "\n")
    }
}
