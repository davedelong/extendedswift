//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import Foundation

extension Clock where Self == UserClock {
    
    public static var user: UserClock { UserClock() }
    
}

public struct UserClock: Clock {
    public typealias Instant = Date
    public typealias Duration = Instant.Duration
    
    public init() {
        
    }
    
    public var now: Date {
        return Date()
    }
    
    public var minimumResolution: Instant.Duration {
        return Duration(secondsComponent: 0, attosecondsComponent: Int64(NSEC_PER_SEC))
    }
    
    public func sleep(until deadline: Date, tolerance: Duration?) async throws {
        let time = deadline.timeIntervalSince1970 - now.timeIntervalSince1970
        if time <= 0 { return }
        let nSec = time * Double(NSEC_PER_SEC)
        try await Task.sleep(nanoseconds: UInt64(nSec))
    }
}
