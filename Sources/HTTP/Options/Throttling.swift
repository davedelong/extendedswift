public enum HTTPThrottleBehavior: Sendable, Equatable {
    case throttled
    case unthrottled
}

extension HTTPOptions {
    
    public var throttleBehavior: HTTPThrottleBehavior {
        get { self[HTTPThrottleOption.self] }
        set { self[HTTPThrottleOption.self] = newValue }
    }
    
}

private enum HTTPThrottleOption: HTTPOption {
    static let defaultValue: HTTPThrottleBehavior = .throttled
}
