//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import Foundation

private let ASEC_PER_SEC = 1e18

extension Date: InstantProtocol {
    public typealias Duration = Swift.Duration
    
    public func advanced(by duration: Duration) -> Date {
        var distance = TimeInterval(duration.components.seconds)
        distance += TimeInterval(duration.components.attoseconds) / ASEC_PER_SEC
        return self.addingTimeInterval(distance)
    }
    
    public func duration(to other: Date) -> Duration {
        let distance = other.timeIntervalSince1970 - self.timeIntervalSince1970
        let wholeSeconds = distance.rounded(.towardZero)
        let subSeconds = distance - wholeSeconds
        
        return Duration(secondsComponent: Int64(wholeSeconds),
                        attosecondsComponent: Int64(subSeconds * ASEC_PER_SEC))
    }
    
}
