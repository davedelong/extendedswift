//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/26/23.
//

import Foundation

extension Encoder {
    
    public var encodingError: EncodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
    public func errorContext(for key: CodingKey? = nil, debugDescription: String, underlyingError: Error? = nil) -> EncodingError.Context {
        var newPath = codingPath
        if let key { newPath.append(key) }
        return .init(codingPath: newPath,
                     debugDescription: debugDescription,
                     underlyingError: underlyingError)
    }
    
}

extension KeyedEncodingContainer {
    
    public var encodingError: EncodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension KeyedEncodingContainerProtocol {
    
    public var encodingError: EncodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension UnkeyedEncodingContainer {
    
    public var encodingError: EncodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension SingleValueEncodingContainer {
    
    public var encodingError: EncodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

public struct EncodingErrorBuilder<P> {
    let provider: P
    let codingPath: Array<CodingKey>
    
    public func context(debugDescription: String = "", underlyingError: Error? = nil) -> EncodingError.Context {
        return EncodingError.Context(codingPath: codingPath,
                                     debugDescription: debugDescription,
                                     underlyingError: underlyingError)
    }
    
    public func invalidValue(_ value: Any, _ debugDescription: String = "", underlyingError: Error? = nil) -> EncodingError {
        
        let ctx = context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .invalidValue(value, ctx)
        
    }
}
