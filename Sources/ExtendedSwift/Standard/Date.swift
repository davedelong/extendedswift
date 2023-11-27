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
    
}
