//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/17/23.
//

import Foundation

extension Data {
    
    public init?(hexString: String) {
        guard hexString.allSatisfy(\.isHexDigit) else { return nil }
        guard hexString.count.isMultiple(of: 2) else { return nil }
        
        let bytes = hexString.chunks(ofCount: 2).compactMap { UInt8($0, radix: 16) }
        guard bytes.count == hexString.count / 2 else { return nil }
        
        self.init(bytes)
    }
    
    public var hexDescription: String {
        return self.map { String(format: "%02X", $0) }.joined()
    }
    
}
