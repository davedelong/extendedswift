public struct HTTPHeader: Hashable, Sendable, ExpressibleByStringLiteral {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.normalized == rhs.normalized
    }
    
    private let normalized: String
    public let rawValue: String
    
    public init(rawValue: String) {
        self.normalized = rawValue.lowercased()
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(normalized)
    }
}

extension HTTPHeader {
    
    // Based on https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
    
    public static let accept = HTTPHeader(rawValue: "Accept")
    public static let acceptCharset = HTTPHeader(rawValue: "Accept-Charset")
    public static let acceptEncoding = HTTPHeader(rawValue: "Accept-Encoding")
    public static let acceptLanguage = HTTPHeader(rawValue: "Accept-Language")
    public static let authorization = HTTPHeader(rawValue: "Authorization")
    public static let cacheControl = HTTPHeader(rawValue: "Cache-Control")
    public static let connection = HTTPHeader(rawValue: "Connection")
    public static let contentEncoding = HTTPHeader(rawValue: "Content-Encoding")
    public static let contentLength = HTTPHeader(rawValue: "Content-Length")
    public static let contentType = HTTPHeader(rawValue: "Content-Type")
    public static let cookie = HTTPHeader(rawValue: "Cookie")
    public static let date = HTTPHeader(rawValue: "Date")
    public static let doNotTrack = HTTPHeader(rawValue: "DNT")
    public static let host = HTTPHeader(rawValue: "Host")
    public static let ifMatch = HTTPHeader(rawValue: "If-Match")
    public static let ifModifiedSince = HTTPHeader(rawValue: "If-Modified-Since")
    public static let ifNoneMatch = HTTPHeader(rawValue: "If-None-Match")
    public static let ifRange = HTTPHeader(rawValue: "If-Range")
    public static let ifUnmodifiedSince = HTTPHeader(rawValue: "If-Unmodified-Since")
    public static let origin = HTTPHeader(rawValue: "Origin")
    public static let range = HTTPHeader(rawValue: "Range")
    public static let referer = HTTPHeader(rawValue: "Referer")
    public static let transferEncoding = HTTPHeader(rawValue: "Transfer-Encoding")
    public static let userAgent = HTTPHeader(rawValue: "User-Agent")
    
    public static let contentDisposition = HTTPHeader(rawValue: "Content-Disposition")
    public static let contentLanguage = HTTPHeader(rawValue: "Content-Language")
    public static let contentLocation = HTTPHeader(rawValue: "Content-Location")
    public static let contentRange = HTTPHeader(rawValue: "Content-Range")
    public static let etag = HTTPHeader(rawValue: "ETag")
    public static let lastModified = HTTPHeader(rawValue: "Last-Modified")
    public static let location = HTTPHeader(rawValue: "Location")
    public static let retryAfter = HTTPHeader(rawValue: "Retry-After")
    public static let setCookie = HTTPHeader(rawValue: "Set-Cookie")
    public static let wwwAuthenticate = HTTPHeader(rawValue: "WWW-Authenticate")
    
}
