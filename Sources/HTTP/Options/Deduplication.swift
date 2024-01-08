
extension HTTPOptions {
    
    public var deduplicationIdentifier: String? {
        get { self[HTTPDeduplicationIdentifier.self] }
        set { self[HTTPDeduplicationIdentifier.self] = newValue }
    }
    
}

private enum HTTPDeduplicationIdentifier: HTTPOption {
    static let defaultValue: String? = nil
}
