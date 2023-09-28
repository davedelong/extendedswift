//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import Foundation

extension Clock {
    
    public func mutableClock() -> MutableClock<Self> {
        return MutableClock(clock: self)
    }
    
    public func manualClock() -> ManualClock<Self> {
        return ManualClock(base: self)
    }
}
