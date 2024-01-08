//
//  File.swift
//  
//

import Foundation

public struct DataBody: HTTPSynchronousBody {
    
    public let bodyData: Data
    
    public let headers: HTTPHeaders
    
    public init(_ data: Data, headers: HTTPHeaders? = nil) {
        self.bodyData = data
        self.headers = headers ?? .init()
    }
    
    public var stream: AsyncStream<UInt8> {
        return AsyncStream(sequence: bodyData)
    }
    
}

extension Data: HTTPSynchronousBody {
    
    public var bodyData: Data { self }
    
}
