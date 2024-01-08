//
//  File.swift
//  
//

import Foundation

public struct FormBody: HTTPSynchronousBody {
    
    public let headers: HTTPHeaders
    
    public var bodyData: Data {
        Data(values.map { (key, value) -> String in
            let k = key.addingPercentEncoding(withAllowedCharacters: formBodyAllowed) ?? ""
            let v = value.addingPercentEncoding(withAllowedCharacters: formBodyAllowed) ?? ""
            return "\(k)=\(v)"
        }.joined(separator: "&").utf8)
    }
    
    public let values: Dictionary<String, String>
    
    public init(values: Dictionary<String, String>) {
        self.values = values
        self.headers = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
        ]
    }
}

private let formBodyAllowed = CharacterSet(charactersIn: "&=:/, $%+").inverted
