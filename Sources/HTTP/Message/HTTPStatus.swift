public struct HTTPStatus: RawRepresentable, Hashable, Comparable, Sendable, CustomStringConvertible {
    
    public static func < (lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public let rawValue: Int
    public let statusMessage: String?
    
    public var description: String {
        if let statusMessage {
            return "\(rawValue) \(statusMessage)"
        } else {
            return "\(rawValue)"
        }
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
        self.statusMessage = Self.defaultStatusMessages[rawValue]
    }
    
    public init(rawValue: Int, statusMessage: String?) {
        self.rawValue = rawValue
        self.statusMessage = statusMessage
    }
    
    public var isInformational: Bool { return 100 ..< 200 ~= rawValue }
    public var isSuccess: Bool { return 200 ..< 300 ~= rawValue }
    public var isRedirecton: Bool { return 300 ..< 400 ~= rawValue }
    public var isClientError: Bool { return 400 ..< 500 ~= rawValue }
    public var isServerError: Bool { return 500 ..< 600 ~= rawValue }
    
}

extension HTTPStatus {
    
    // Based on https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
    
    public static let `continue` = HTTPStatus(rawValue: 100)
    public static let switchingProtocols = HTTPStatus(rawValue: 101)
    public static let processing = HTTPStatus(rawValue: 102)
    
    public static let ok = HTTPStatus(rawValue: 200)
    public static let created = HTTPStatus(rawValue: 201)
    public static let noContent = HTTPStatus(rawValue: 204)
    
    public static let multipleChoices = HTTPStatus(rawValue: 300)
    public static let movedPermanently = HTTPStatus(rawValue: 301)
    public static let found = HTTPStatus(rawValue: 302)
    public static let notModified = HTTPStatus(rawValue: 304)
    public static let temporaryRedirect = HTTPStatus(rawValue: 307)
    public static let permanentRedirect = HTTPStatus(rawValue: 308)
    
    public static let badRequest = HTTPStatus(rawValue: 400)
    public static let unauthorized = HTTPStatus(rawValue: 401)
    public static let forbidden = HTTPStatus(rawValue: 403)
    public static let notFound = HTTPStatus(rawValue: 404)
    public static let methodNotAllowed = HTTPStatus(rawValue: 405)
    public static let requestTimeout = HTTPStatus(rawValue: 408)
    public static let conflict = HTTPStatus(rawValue: 409)
    public static let gone = HTTPStatus(rawValue: 410)
    
    public static let internalServerError = HTTPStatus(rawValue: 500)
    public static let notImplemented = HTTPStatus(rawValue: 501)
    public static let badGateway = HTTPStatus(rawValue: 502)
    public static let serviceUnavailable = HTTPStatus(rawValue: 503)
    
}


extension HTTPStatus {
    
    public static let defaultStatusMessages: Dictionary<HTTPStatus.RawValue, String> = [
        100: "Continue",
        101: "Switching Protocols",
        102: "Processing",
        
        200: "OK",
        201: "Created",
        204: "No Content",
        
        300: "Multiple Choices",
        301: "Moved Permanently",
        302: "Found",
        304: "Not Modified",
        307: "Temporary Redirect",
        308: "Permanent Redirect",
        
        400: "Bad Request",
        401: "Unauthorized",
        403: "Forbidden",
        404: "Not Found",
        405: "MethodNotAllowed",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
    ]
    
}
