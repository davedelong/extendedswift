//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import Foundation

public final class ManualClock<C: Clock>: Clock, @unchecked Sendable {
    public typealias Instant = C.Instant
    public typealias Duration = C.Duration
    
    private let inner: C
    private var _now: Instant
    private var pendingSleeps = Dictionary<Instant, [CheckedContinuation<Void, Never>]>()
    
    public init(base: C) {
        self.inner = base
        self._now = base.now
    }
    
    public var now: Instant {
        get {
            return _now
        }
        set {
            _now = newValue
            let pastDeadlines = pendingSleeps.keys.sorted(by: <).filter { $0 < newValue }
            let continuations = pastDeadlines.flatMap { pendingSleeps[$0] ?? [] }
            for deadline in pastDeadlines {
                pendingSleeps.removeValue(forKey: deadline)
            }
            
            for continuation in continuations {
                continuation.resume()
            }
        }
    }
    
    public var minimumResolution: C.Duration { inner.minimumResolution }
    
    public func sleep(until deadline: C.Instant, tolerance: C.Instant.Duration?) async throws {
        await withCheckedContinuation { continuation in
            self.pendingSleeps[deadline, default: []].append(continuation)
        }
    }
    
    public func advance(by duration: Duration) {
        self.now = _now.advanced(by: duration)
    }
}
