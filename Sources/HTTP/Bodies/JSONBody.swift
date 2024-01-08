//
//  File.swift
//
//

import Foundation

public struct JSONBody<E: Encodable & Sendable>: HTTPSynchronousBody {
    
    public let encoder: JSONEncoder
    public let value: E
    
    public var bodyData: Data {
        get throws {
            try encoder.encode(value)
        }
    }
    
    public let headers: HTTPHeaders
    
    public init(value: E, encoder: JSONEncoder? = nil) {
        self.encoder = encoder ?? JSONEncoder()
        self.value = value
        self.headers = [
            "Content-Type": "application/json; charset=utf-8"
        ]
    }
}
