//
//  Dispatch.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/17/25.
//

import Dispatch

extension DispatchQueue {
    
    public func async(after duration: Duration, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping () -> Void) {
        let components = duration.components
        let nanoseconds = (UInt64(components.seconds) * UInt64(NSEC_PER_SEC)) + (UInt64(components.attoseconds) * UInt64(1e9))
        let time = DispatchTime.now().advanced(by: .nanoseconds(Int(nanoseconds)))
        self.asyncAfter(deadline: time, qos: qos, flags: flags, execute: work)
    }
    
}
