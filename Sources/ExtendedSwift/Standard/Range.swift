//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension ClosedRange {
    
    public func clamping(_ value: Bound) -> Bound {
        if value < lowerBound { return lowerBound }
        if value > upperBound { return upperBound }
        return value
    }
    
}

extension Comparable {
    
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return range.clamping(self)
    }
    
}
