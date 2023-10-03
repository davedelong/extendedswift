//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension FixedWidthInteger {
    
    public static func lcm(_ values: Self...) -> Self {
        return self.lcm(of: values)
    }
    
    public static func lcm(of values: some Collection<Self>) -> Self {
        let v = values.first!
        let r = values.dropFirst()
        if r.isEmpty { return v }
        
        let lcmR = lcm(of: r)
        return v / gcd(of: v, and: lcmR) * lcmR
    }
    
    public static func gcd(of m: Self, and n: Self) -> Self {
        var a = Self.zero
        var b = Swift.max(m, n)
        var r = Swift.min(m, n)
        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        return b
    }
    
    public func swapping(_ shouldSwap: Bool) -> Self {
        guard shouldSwap else { return self }
        return self.byteSwapped
    }
    
}
