//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/27/23.
//

import Foundation

extension Date {
    
    public static func - (lhs: Self, rhs: Self) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    public static func - (lhs: Self, rhs: TimeInterval) -> Self {
        return lhs.addingTimeInterval(-rhs)
    }
    
    public static func + (lhs: Self, rhs: TimeInterval) -> Self {
        return lhs.addingTimeInterval(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: TimeInterval) {
        lhs = lhs.addingTimeInterval(-rhs)
    }
    
    public static func += (lhs: inout Self, rhs: TimeInterval) {
        lhs = lhs.addingTimeInterval(rhs)
    }
    
    public static func time(_ work: () throws -> Void) rethrows -> TimeInterval {
        let start = Date()
        try work()
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    public static func time(_ work: () async throws -> Void) async rethrows -> TimeInterval {
        let start = Date()
        try await work()
        let end = Date()
        return end.timeIntervalSince(start)
    }
}
