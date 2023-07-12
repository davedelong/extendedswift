//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import Logging

extension Logger.MetadataValue: Codable {
    
    public init(from decoder: Decoder) throws {
        if var u = try? decoder.unkeyedContainer() {
            var a = Array<Logger.MetadataValue>()
            while u.isAtEnd == false {
                a.append(try u.decode(Self.self))
            }
            self = .array(a)
        } else if let k = try? decoder.container(keyedBy: AnyCodingKey.self) {
            var d = Logger.Metadata()
            for key in k.allKeys {
                d[key.stringValue] = try k.decode(Self.self, forKey: key)
            }
            self = .dictionary(d)
        } else if let s = try? decoder.singleValueContainer() {
            let string = try s.decode(String.self)
            self = .string(string)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode MetadataValue"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .array(let values):
                var unkeyed = encoder.unkeyedContainer()
                for v in values { try unkeyed.encode(v) }
            case .dictionary(let d):
                var keyed = encoder.container(keyedBy: AnyCodingKey.self)
                for (k, v) in d {
                    try keyed.encode(v, forKey: AnyCodingKey(stringValue: k))
                }
            case .string(let s):
                var single = encoder.singleValueContainer()
                try single.encode(s)
            case .stringConvertible(let s):
                var single = encoder.singleValueContainer()
                try single.encode(s.description)
        }
    }
}
