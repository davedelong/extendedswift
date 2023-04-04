//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

public struct ID<Base, RawValue>: Newtype, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension ID: Equatable where RawValue: Equatable { }
extension ID: Hashable where RawValue: Hashable { }
extension ID: Identifiable where RawValue: Identifiable { }
extension ID: Decodable where RawValue: Decodable { }
extension ID: Encodable where RawValue: Encodable { }
