//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation

extension String.StringInterpolation {
    
    public mutating func appendInterpolation<Value>(describing value: Value?) {
        self.appendInterpolation(String(describing: value))
    }
    
    public mutating func appendInterpolation<Value: BinaryInteger>(hex value: Value) {
        self.appendInterpolation("0x" + String(value, radix: 16, uppercase: true))
    }
}

