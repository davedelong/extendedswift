//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

// MARK: - Decoding Extensions

extension DecodingError {
    
    public var context: DecodingError.Context? {
        switch self {
            case .typeMismatch(_, let ctx):
                return ctx
            case .valueNotFound(_, let ctx):
                return ctx
            case .keyNotFound(_, let ctx):
                return ctx
            case .dataCorrupted(let ctx):
                return ctx
            @unknown default:
                return nil
        }
    }
    
    public var codingPath: Array<CodingKey> {
        return self.context?.codingPath ?? []
    }
    
    public var codingPathDescription: String {
        prettyPath(codingPath)
    }
    
}

extension DecodingError.Context {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension Decoder {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension KeyedDecodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension KeyedDecodingContainerProtocol {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension UnkeyedDecodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension SingleValueDecodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

// MARK: - Encoding Extensions

extension Encoder {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension EncodingError {
    
    public var context: Context? {
        switch self {
            case .invalidValue(_, let ctx): return ctx
            @unknown default: return nil
        }
    }
    
    public var codingPath: Array<CodingKey> {
        switch self {
            case .invalidValue(_, let ctx): return ctx.codingPath
            @unknown default: return []
        }
    }
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension EncodingError.Context {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension KeyedEncodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension KeyedEncodingContainerProtocol {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension UnkeyedEncodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

extension SingleValueEncodingContainer {
    
    public var codingPathDescription: String {
        return prettyPath(codingPath)
    }
    
}

internal func prettyPath(_ parts: Array<CodingKey>) -> String {
    let components = parts.enumerated().map { (offset, key) -> String in
        if let idx = key.intValue {
            if offset > 0 {
                return "[\(idx)]"
            } else {
                return ".[\(idx)]"
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
