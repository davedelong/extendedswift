//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Decoder {
    
    public func errorContext(for key: CodingKey, debugDescription: String, underlyingError: Error? = nil) -> DecodingError.Context {
        return .init(codingPath: codingPath + [key],
                     debugDescription: debugDescription,
                     underlyingError: underlyingError)
    }
    
}

extension DecodingError.Context {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
}

extension Encoder {
    
    public func errorContext(for key: CodingKey, debugDescription: String, underlyingError: Error? = nil) -> EncodingError.Context {
        return .init(codingPath: codingPath + [key],
                     debugDescription: debugDescription,
                     underlyingError: underlyingError)
    }
    
}

extension EncodingError.Context {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
}

fileprivate func prettyPath(_ parts: Array<CodingKey>) -> String {
    let components = parts.enumerated().map { (offset, key) -> String in
        if let idx = key.intValue {
            if offset == 0 {
                return ".[\(idx)]"
            } else {
                return "[\(idx)]"
            }
        } else {
            if offset > 0 {
                return ".\(key.stringValue)"
            } else {
                return key.stringValue
            }
        }
    }
    
    return components.joined()
}
