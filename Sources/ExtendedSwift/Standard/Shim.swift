//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/13/23.
//

import Foundation

public struct Shim<Namespace, Value> {
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
}
