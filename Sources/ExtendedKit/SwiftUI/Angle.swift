//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/12/24.
//

import Foundation
import ExtendedSwift
import SwiftUI

// option-shift-8 on US keyboards
postfix operator °

extension Double {
    
    public static postfix func °(lhs: Double) -> Angle {
        return Angle(degrees: lhs)
    }
    
}

extension Angle {
    
    public init(clockHour: Int, cycle: Locale.HourCycle = .oneToTwelve) {
        let up = 270.0
        let degreesPerHour = 360.0 / Double(cycle.numberOfHours)
        self.init(degrees: up + (Double(clockHour) * degreesPerHour))
    }
    
    public init(clockMinute: Int) {
        let up = 270.0
        let degreesPerMinute = 360.0 / 60.0
        self.init(degrees: up + (Double(clockMinute) * degreesPerMinute))
    }
    
}

extension CGPoint {
    
    public init(angle: Angle, length: Double) {
        self.init(polarAngle: angle.radians, length: length)
    }
    
}

extension Locale.HourCycle {
    
    fileprivate var numberOfHours: Int {
        switch self {
            case .oneToTwelve: return 12
            case .zeroToEleven: return 12
            case .oneToTwentyFour: return 24
            case .zeroToTwentyThree: return 24
            @unknown default: return 12
        }
    }
    
}
