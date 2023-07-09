//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import Foundation

extension Encoder {
    
    public func anyKeyedContainer() -> KeyedEncodingContainer<AnyCodingKey> {
        self.container(keyedBy: AnyCodingKey.self)
    }
    
}

extension KeyedEncodingContainer {
    
    public mutating func encode<E: Encodable & Collection>(ifNotEmpty value: E?, key: Key) throws {
        guard let value else { return }
        guard value.isEmpty == false else { return }
        try self.encode(value, forKey: key)
    }
    
}

extension UnkeyedEncodingContainer {
    
    public mutating func encode<E: Encodable & Collection>(ifNotEmpty value: E?) throws {
        guard let value else { return }
        guard value.isEmpty == false else { return }
        try self.encode(value)
    }
    
}
