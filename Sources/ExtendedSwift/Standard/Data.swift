//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/17/23.
//

import Foundation

extension RangeReplaceableCollection where Element == UInt8 {
    
    public init?(hexDescription: String) {
        guard hexDescription.allSatisfy(\.isHexDigit) else { return nil }
        guard hexDescription.count.isMultiple(of: 2) else { return nil }
        
        let bytes = hexDescription.chunks(ofCount: 2).compactMap { UInt8($0, radix: 16) }
        guard bytes.count == hexDescription.count / 2 else { return nil }
        
        self.init(bytes)
    }
        
    public init(randomByteCount: Int) throws {
        self = try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: randomByteCount, { ptr in
            let status = SecRandomCopyBytes(kSecRandomDefault, randomByteCount, ptr.baseAddress!)
            guard status == errSecSuccess else {
                var userInfo: Dictionary<String, Any>?
                if let message = SecCopyErrorMessageString(status, nil) {
                    userInfo = [NSLocalizedDescriptionKey: message]
                }
                throw NSError(domain: "OSStatus", code: Int(status), userInfo: userInfo)
            }
            
            var collection = Self()
            collection.append(contentsOf: ptr)
            return collection
        })
    }
    
}

extension Collection where Element == UInt8 {
    
    public var hexDescription: String {
        return self.map { String(format: "%02X", $0) }.joined()
    }
    
}
