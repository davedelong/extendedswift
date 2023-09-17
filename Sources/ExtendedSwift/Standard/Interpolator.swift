//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import Foundation

public protocol Interpolator {
    func interpolate(_ number: Double) -> Normalized
    func reverseInterpolate(_ number: Normalized) -> Double
}

extension Interpolator where Self == LinearInterpolator {
    
    public static func linear(_ range: ClosedRange<Double>) -> Self {
        return LinearInterpolator(range)
    }
    
}

extension Interpolator where Self == LogarithmicInterpolator {
    
    public static func logarithmic(_ range: ClosedRange<Double>, scale: Double = 1.0) -> Self {
        return LogarithmicInterpolator(range, scale: scale)
    }
    
}

public struct LinearInterpolator: Interpolator {
    
    public let range: ClosedRange<Double>
    private let span: Double
    
    public init(_ range: ClosedRange<Double>) {
        self.range = range
        self.span = range.upperBound - range.lowerBound
    }
    
    public func interpolate(_ number: Double) -> Normalized {
        return Normalized(number, in: range)
    }
    
    public func reverseInterpolate(_ number: Normalized) -> Double {
        return (number.rawValue * span) + range.lowerBound
    }
    
}

public struct LogarithmicInterpolator: Interpolator {
    
    public let range: ClosedRange<Double>
    public let scale: Double
    private let span: Double
    
    public init(_ range: ClosedRange<Double>, scale: Double = 1.0) {
        self.range = range
        self.span = range.upperBound - range.lowerBound
        self.scale = scale
    }
    
    public func interpolate(_ number: Double) -> Normalized {
        let clamped = number.clamped(to: range)
        let logMin = log1p(range.lowerBound)
        let logRange = log1p(range.upperBound) - log1p(range.lowerBound)
        
        let interpolated = (log1p(clamped) - logMin) / logRange
        if scale <= 0 || scale == 1 {
            return Normalized(rawValue: interpolated)
        } else {
            return Normalized(rawValue: pow(interpolated, 1.0 / scale))
        }
    }
    
    public func reverseInterpolate(_ number: Normalized) -> Double {
        let logMin = log1p(range.lowerBound)
        let logRange = log1p(range.upperBound) - log1p(range.lowerBound)
        
        var input = number.rawValue
        if scale > 0 && scale != 1 { input = pow(number.rawValue, scale) }
        return expm1((input * logRange) + logMin)
    }
    
}
