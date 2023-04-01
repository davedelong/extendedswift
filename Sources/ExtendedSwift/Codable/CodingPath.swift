//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension DecodingError.Context {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
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
            return "[\(idx)]"
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
