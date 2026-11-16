//
//  SwiftUIView.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/8/26.
//

import Foundation

extension String: @retroactive CodingKey {
    
    public var stringValue: String { self }
    public var intValue: Int? { Int(self) }
    
    public init?(stringValue: String) {
        self = stringValue
    }
    
    public init?(intValue: Int) {
        self = "\(intValue)"
    }
    
}
