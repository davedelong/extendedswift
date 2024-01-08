import Foundation

extension HTTPOptions {
    
    /// Indicates how the request should be retried if it is not cancelled.
    ///
    /// The default value is `nil`, which means the request will not be retried.
    public var retryStrategy: (any HTTPRetryStrategy)? {
        get { self[HTTPRetryOption.self] }
        set { self[HTTPRetryOption.self] = newValue }
    }
    
}

public protocol HTTPRetryStrategy {
    mutating func nextDelay(after result: HTTPResult) -> TimeInterval?
}

public struct BackoffRetry: HTTPRetryStrategy {
    private var delays: Array<TimeInterval>
    
    public static func immediately(maximumNumberOfAttempts: Int) -> HTTPRetryStrategy {
        let count = max(maximumNumberOfAttempts - 1, 0)
        return explicit(delays: Array(repeating: 0, count: count))
    }
    
    public static func linear(delay: TimeInterval, maximumNumberOfAttempts: Int) -> HTTPRetryStrategy {
        let count = max(maximumNumberOfAttempts - 1, 0)
        return explicit(delays: Array(repeating: delay, count: count))
    }
    
    public static func exponential(maximumNumberOfAttempts: Int) -> HTTPRetryStrategy {
        let count = max(maximumNumberOfAttempts, 0)
        let delays = (0 ..< count).map { TimeInterval(pow(1.5, Double($0))) }
        return explicit(delays: delays)
    }
    
    public static func explicit(delays: Array<TimeInterval>) -> HTTPRetryStrategy {
        return BackoffRetry(delays: delays)
    }
    
    private init(delays: Array<TimeInterval>) {
        self.delays = delays
    }
    
    public mutating func nextDelay(after result: HTTPResult) -> TimeInterval? {
        guard result.isFailure else { return nil }
        guard delays.isEmpty == false else { return nil }
        return delays.removeFirst()
    }
}

public struct CustomRetry: HTTPRetryStrategy {
    
    private let computeDelay: (HTTPResult) -> TimeInterval?
    
    public init(_ delay: @escaping (HTTPResult) -> TimeInterval?) {
        self.computeDelay = delay
    }
    
    public func nextDelay(after result: HTTPResult) -> TimeInterval? {
        return computeDelay(result)
    }
    
}

private enum HTTPRetryOption: HTTPOption {
    static let defaultValue: HTTPRetryStrategy? = nil
}
