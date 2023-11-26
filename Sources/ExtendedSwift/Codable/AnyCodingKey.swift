//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

public struct AnyCodingKey: CodingKey {
    
    public var stringValue: String
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
    
    public init<Other: CodingKey>(_ other: Other) {
        self.stringValue = other.stringValue
        self.intValue = other.intValue
    }
    
}

extension AnyCodingKey: ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
    public init(integerLiteral value: Int) {
        self.intValue = value
        self.stringValue = "\(value)"
    }
    
    public init(stringLiteral value: String) {
        self.intValue = nil
        self.stringValue = value
    }
}
