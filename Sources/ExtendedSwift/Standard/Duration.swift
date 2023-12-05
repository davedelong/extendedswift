//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/2/23.
//

import Foundation

extension Duration {
    
    public static func measure(_ work: () throws -> Void) rethrows -> Self {
        return try ContinuousClock().measure(work)
    }
    
    public static func measure(_ work: () async throws -> Void) async rethrows -> Self {
        return try await ContinuousClock().measure(work)
    }
    
    public var formattedDescription: String {
        var time = Double(components.seconds) + (Double(components.attoseconds) / 1.0e18)
        let unit: String
        if time > 1.0 {
          unit = "s"
        } else if time > 0.001 {
          unit = "ms"
          time *= 1_000
        } else if time > 0.000_001 {
          unit = "µs"
          time *= 1_000_000
        } else {
          unit = "ns"
          time *= 1_000_000_000
        }
        return timeFormatter.string(from: NSNumber(value: time))! + unit
    }
    
}

private let timeFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.maximumFractionDigits = 3
    return f
}()
