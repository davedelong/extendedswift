//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/7/23.
//

import Foundation

extension Scanner where Element == UInt8 {
    
    private mutating func scanBinaryInteger<BI: BinaryInteger>() throws -> BI {
        let data = try scan(count: MemoryLayout<BI>.size)
        return data.reversed().reduce(BI.zero) { $0 << 8 + BI($1) }
    }
    
    @discardableResult
    public mutating func scan<BI: BinaryInteger>(_ type: BI.Type = BI.self) throws -> BI {
        return try scanBinaryInteger()
    }
    
    @discardableResult
    public mutating func scanUInt32() throws -> UInt32 {
        return try scanBinaryInteger()
    }
    
    @discardableResult
    public mutating func scanStruct<T>(_ type: T.Type = T.self) throws -> T {
        let bytes = try scan(count: MemoryLayout<T>.size)
        let data = Data(bytes)
        return data.withUnsafeBytes { $0.load(as: type) }
    }
    
}
