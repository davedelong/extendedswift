import Foundation

public protocol HTTPBody: Sendable {
    
    var headers: HTTPHeaders { get }
    var stream: AsyncStream<UInt8> { get throws }
    
}

public protocol HTTPSynchronousBody: HTTPBody {
    
    var bodyData: Data { get throws }
    
}

extension HTTPBody {
    
    public var headers: HTTPHeaders {
        return .init()
    }
    
}

extension HTTPSynchronousBody {
    
    public var stream: AsyncStream<UInt8> {
        get throws {
            AsyncStream(sequence: try self.bodyData)
        }
    }
    
}
