//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/24/23.
//

import Foundation

extension UserDefaults {
    
    public func encode<V: Encodable>(_ value: V, forKey key: String) throws {
        let encoded = try PlistEncoder().encode(value)
        self.set(encoded, forKey: key)
    }
    
    public func decode<V: Decodable>(_ type: V.Type = V.self, forKey key: String) throws -> V {
        guard let value = self.object(forKey: key) else {
            throw DecodingError.keyNotFound(AnyCodingKey(stringValue: key),
                                            DecodingError.Context(codingPath: [], debugDescription: ""))
        }
        return try PlistDecoder().decode(from: value)
    }
    
    public func decodeIfPresent<V: Decodable>(_ type: V.Type = V.self, forKey key: String) throws -> V? {
        guard let value = self.object(forKey: key) else {
            return nil
        }
        return try PlistDecoder().decode(from: value)
    }
}
