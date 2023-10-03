//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation

extension UnsafePointer {
    
    public func rebound<T>(to type: T.Type) -> UnsafePointer<T> {
        return self.withMemoryRebound(to: type, capacity: 1, { return $0 })
    }
    
}

extension UnsafeBufferPointer {
    
    public init?(pointer: UnsafeRawPointer, count: Int) where Element == UInt8 {
        let ptr = pointer.assumingMemoryBound(to: UInt8.self)
        self.init(start: ptr, count: count)
    }
    
}

extension Data {
    
    public init(pointer: UnsafeRawPointer, count: Int) {
        let bytes = pointer.assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: bytes, count: count)
        self.init(buffer: buffer)
    }
    
}
