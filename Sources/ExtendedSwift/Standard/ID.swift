//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation
private import Synchronization

public struct ID<Base, RawValue>: Newtype, RawRepresentable, CustomStringConvertible {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        "ID<\(Base.self)>(\(rawValue))"
    }
}

extension ID where RawValue == Int {
    
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public init() {
        self.rawValue = idCounter.withLock {
            let id = ObjectIdentifier(Base.self)
            let nextCounter = $0[id, default: 0]
            $0[id, default: 0] += 1
            return nextCounter
        }
    }
    
    
    public init(rawValue: Int) {
        if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            self.rawValue = idCounter.withLock {
                let id = ObjectIdentifier(Base.self)
                $0[id] = Swift.max($0[id, default: 0], rawValue)
                return rawValue
            }
        } else {
            self.rawValue = rawValue
        }
    }
    
}

extension ID: Equatable where RawValue: Equatable { }
extension ID: Hashable where RawValue: Hashable { }
extension ID: Identifiable where RawValue: Identifiable { }
extension ID: Decodable where RawValue: Decodable { }
extension ID: Encodable where RawValue: Encodable { }

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
private let idCounter = Mutex<[ObjectIdentifier: Int]>([:])
