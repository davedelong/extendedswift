//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension FixedWidthInteger {
    
    public static func leastCommonMultiple(_ values: Self...) -> Self {
        return self.leastCommonMultiple(of: values)
    }
    
    public static func leastCommonMultiple(of values: some Collection<Self>) -> Self {
        if values.isEmpty { return .zero }
        let v = values.first!
        let r = values.dropFirst()
        if r.isEmpty { return v }
        
        let lcmR = leastCommonMultiple(of: r)
        return v / greatestCommonDivisor(of: v, and: lcmR) * lcmR
    }
    
    public static func greatestCommonDivisor(of m: Self, and n: Self) -> Self {
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
    
    @available(*, deprecated, renamed: "leastCommonMultiple")
    public static func lcm(_ values: Self...) -> Self {
        return self.leastCommonMultiple(of: values)
    }
    
    @available(*, deprecated, renamed: "leastCommonMultiple")
    public static func lcm(of values: some Collection<Self>) -> Self {
        return self.leastCommonMultiple(of: values)
    }
    
    @available(*, deprecated, renamed: "greatestCommonDivisor")
    public static func gcd(of m: Self, and n: Self) -> Self {
        return self.greatestCommonDivisor(of: m, and: n)
    }
    
}
