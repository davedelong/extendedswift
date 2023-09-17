//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/13/23.
//

import Foundation

public struct Normalized {
    
    public let rawValue: Double
    
    public init(rawValue: Double) {
        self.rawValue = rawValue.clamped(to: 0 ... 1)
    }
    
    public init<FP: BinaryFloatingPoint>(_ value: FP, in range: ClosedRange<FP>) {
        let span = Double(range.upperBound - range.lowerBound)
        let val = Double(value - range.lowerBound)
        self.rawValue = val / span
    }
    
    public init<I: BinaryInteger>(_ value: I, in range: ClosedRange<I>) {
        let span = Double(range.upperBound - range.lowerBound)
        let val = Double(value - range.lowerBound)
        self.rawValue = val / span
    }
    
    public init<I: BinaryInteger>(_ value: I, in range: Range<I>) {
        let closedRange = range.lowerBound ... (range.upperBound - 1)
        self.init(value, in: closedRange)
    }
    
}

