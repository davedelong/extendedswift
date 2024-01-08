import Foundation

public struct HTTPRequest: Sendable, CustomStringConvertible {
    
    public let id = UUID()
    
    public var method: HTTPMethod = .get
    
    public var host: String?
    public var path: String?
    public var fragment: String?
    public var query = HTTPQuery()
    public var headers = HTTPHeaders()
    
    public var options = HTTPOptions()
    
    public var body: (any HTTPBody)?
    
    public init() { }
    
    public init(method: HTTPMethod = .get, url: URL, body: (any HTTPBody)? = nil) {
        self.method = method
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        self.host = components?.host
        self.path = components?.path
        self.fragment = components?.fragment
        
        self.query = HTTPQuery()
        for item in components?.queryItems ?? [] {
            self[query: item.name] = item.value
        }
        
        self.body = body
    }
    
    public init(method: HTTPMethod = .get, host: String? = nil, path: String? = nil, query: HTTPQuery? = nil) {
        self.method = method
        self.host = host
        self.path = path
        self.query = query ?? .init()
        self.body = nil
    }
    
    public subscript(header name: HTTPHeader) -> String? {
        get { headers.firstValue(for: name) }
        set { headers.setValue(newValue, for: name) }
    }
    
    public subscript(headers name: HTTPHeader) -> [String] {
        get { headers[name] }
        set { headers[name] = newValue }
    }
    
    public subscript(query name: String) -> String? {
        get { query.firstValue(for: name) }
        set { query.setValue(newValue, for: name) }
    }
    
    public subscript(queries name: String) -> [String] {
        get { query[name] }
        set { query[name] = newValue }
    }
    
    public subscript<O: HTTPOption>(option type: O.Type) -> O.Value {
        get { options[type] }
        set { options[type] = newValue }
    }
    
    public subscript<V>(option keyPath: WritableKeyPath<HTTPOptions, V>) -> V {
        get { options[keyPath: keyPath] }
        set { options[keyPath: keyPath] = newValue }
    }
    
    public var description: String { descriptionLines.joined(separator: "\n") }
    
    public var descriptionLines: Array<String> {
        var lines = Array<String>()
        
        var path = path ?? "/"
        if let fragment { path += "#\(fragment)" }
        if query.count > 0 {
            var prefix = "?"
            
            for (key, value) in query {
                path += "\(prefix)\(key)=\(value)"
                prefix = "&"
            }
        }
        lines.append("\(method.rawValue) \(path)")
        if let host {
            lines.append("Host: \(host)")
        }
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
