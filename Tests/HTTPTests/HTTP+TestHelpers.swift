import HTTP

extension HTTPRequest {
    
    static func build(using builder: (inout HTTPRequest) -> Void) -> HTTPRequest {
        var request = HTTPRequest()
        builder(&request)
        return request
    }
    
}
