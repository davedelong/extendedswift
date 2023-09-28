//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import Foundation

public final class MutableClock<C: Clock>: Clock, @unchecked Sendable {
    public typealias Instant = C.Instant
    public typealias Duration = C.Duration
    
    private let inner: C
    
    // mutating this is technically not safe
    // however... changing "now" should be very rare
    private var offsetFromInner: Duration
    
    public init(clock: C) {
        self.inner = clock
        self.offsetFromInner = .zero
    }
    
    public var now: Instant {
        get {
            let innerNow = inner.now
            return innerNow.advanced(by: offsetFromInner)
        }
        set {
            let innerNow = inner.now
            self.offsetFromInner = innerNow.duration(to: newValue)
        }
    }
    
    public var minimumResolution: C.Duration {
        inner.minimumResolution
    }
    
    public func reset() {
        self.offsetFromInner = .zero
    }
    
    public func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        let currentNow = self.now
        let timeToWait = currentNow.duration(to: deadline)
        let innerNow = inner.now
        let targetDeadline = innerNow.advanced(by: timeToWait)
        try await inner.sleep(until: targetDeadline, tolerance: tolerance)
    }
    
}
