//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension Range where Bound: Strideable {
    
    public init(start: Bound, length: Bound.Stride) {
        let end = start.advanced(by: length)
        if start <= end {
            self = start ..< end
        } else {
            self = end ..< start
        }
    }
    
}

extension ClosedRange where Bound: Strideable {
    
    public init(start: Bound, length: Bound.Stride) {
        if length == 0 { fatalError("Cannot create an empty ClosedRange") }
        let end = start.advanced(by: length - 1)
        if start <= end {
            self = start ... end
        } else {
            self = end ... start
        }
    }
    
}

extension Range where Bound: Strideable {
    
    public func clamping(_ value: Bound) -> Bound {
        if value < lowerBound { return lowerBound }
        if value >= upperBound { return upperBound.advanced(by: -1) }
        return value
    }
    
}

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

extension Comparable where Self: Strideable {
    
    public func clamped(to range: Range<Self>) -> Self {
        return range.clamping(self)
    }
    
}
