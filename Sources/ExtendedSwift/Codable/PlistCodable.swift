//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/26/23.
//

import Foundation

public class PlistEncoder {
    
    public init() { }
    
    public func encode<T: Encodable>(_ value: T) throws -> Any {
        let wrapper = PlistRootWriter()
        let encoder = _PlistEncoder(codingPath: [], parent: wrapper)
        try value.encode(to: encoder)
        return wrapper.encoded!
    }
    
}

public class PlistDecoder {
    
    public init() { }
    
    public func decode<V: Decodable>(_ type: V.Type = V.self, from plist: Any) throws -> V {
        let decoder = _PlistDecoder(codingPath: [], contents: plist)
        return try V.init(from: decoder)
    }
    
}
