import Foundation

extension HTTPResponse {
    
    internal init(request: HTTPRequest, response: HTTPURLResponse) {
        self.request = request
        self.status = HTTPStatus(rawValue: response.statusCode)
        
        for (anyHeader, anyValue) in response.allHeaderFields {
            let header = HTTPHeader(rawValue: anyHeader.description)
            if let str = anyValue as? String {
                self.headers.addValue(str, for: header)
            } else if let strs = anyValue as? [String] {
                for str in strs {
                    self.headers.addValue(str, for: header)
                }
            } else {
                print("UNKNOWN HEADER VALUE", anyValue)
            }
        }
        
        self.body = nil
    }
    
}
