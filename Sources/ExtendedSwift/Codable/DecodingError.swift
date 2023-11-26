//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/13/23.
//

import Foundation

extension Decoder {
    
    public var decodingError: DecodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
    public func errorContext(for key: CodingKey? = nil, debugDescription: String, underlyingError: Error? = nil) -> DecodingError.Context {
        var newPath = codingPath
        if let key { newPath.append(key) }
        return .init(codingPath: newPath,
                     debugDescription: debugDescription,
                     underlyingError: underlyingError)
    }
    
}

extension KeyedDecodingContainer {
    
    public var decodingError: DecodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension KeyedDecodingContainerProtocol {
    
    public var decodingError: DecodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension UnkeyedDecodingContainer {
    
    public var decodingError: DecodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

extension SingleValueDecodingContainer {
    
    public var decodingError: DecodingErrorBuilder<Self> {
        .init(provider: self, codingPath: codingPath)
    }
    
}

// MARK: - Error Builder

public struct DecodingErrorBuilder<P> {
    let provider: P
    let codingPath: Array<CodingKey>
    
    public func context(debugDescription: String = "", underlyingError: Error? = nil) -> DecodingError.Context {
        return DecodingError.Context(codingPath: codingPath,
                                     debugDescription: debugDescription,
                                     underlyingError: underlyingError)
    }
    
    public func typeMismatch(_ type: Any.Type, _ debugDescription: String = "", underlyingError: Error? = nil) -> DecodingError {
        let ctx = context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .typeMismatch(type, ctx)
    }
    
    public func valueNotFound(_ type: Any.Type, _ debugDescription: String = "", underlyingError: Error? = nil) -> DecodingError {
        let ctx = context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .valueNotFound(type, ctx)
    }

    public func keyNotFound(_ key: P.Key, _ debugDescription: String = "", underlyingError: Error? = nil) -> DecodingError where P: KeyedDecodingContainerProtocol {
        let ctx = context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .keyNotFound(key, ctx)
    }
    
    @_disfavoredOverload
    public func dataCorrupted(_ debugDescription: String = "", underlyingError: Error? = nil) -> DecodingError {
        let ctx = context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .dataCorrupted(ctx)
    }
    
    public func dataCorrupted(for key: P.Key, _ debugDescription: String = "") -> DecodingError where P: KeyedDecodingContainerProtocol {
        return .dataCorruptedError(forKey: key, in: provider, debugDescription: debugDescription)
    }
    
    public func dataCorrupted(_ debugDescription: String = "") -> DecodingError where P: UnkeyedDecodingContainer {
        return .dataCorruptedError(in: provider, debugDescription: debugDescription)
    }
    
    public func dataCorrupted(_ debugDescription: String = "") -> DecodingError where P: SingleValueDecodingContainer {
        return .dataCorruptedError(in: provider, debugDescription: debugDescription)
    }
    
}
