public struct HTTPHeaders: Sendable, Collection {
    
    private var pairs = Pairs<HTTPHeader, String>()
    
    public init() { }
    
    public subscript(name: HTTPHeader) -> [String] {
        get { pairs[name] }
        set { pairs[name] = newValue }
    }
    
    public func firstValue(for header: HTTPHeader) -> String? {
        pairs.firstValue(for: header)
    }
    
    public mutating func setValue(_ value: String?, for header: HTTPHeader) {
        pairs.setValue(value, for: header)
    }
    
    public mutating func addValue(_ value: String, for header: HTTPHeader) {
        pairs.addValue(value, for: header)
    }
    
    public typealias Element = (HTTPHeader, String)
    
    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return pairs.makeIterator()
    }
    
    public var count: Int { pairs.count }
    public var startIndex: Int { pairs.startIndex }
    public var endIndex: Int { pairs.endIndex }
    public subscript(position: Int) -> Element { pairs[position] }
    public func index(after i: Int) -> Int { pairs.index(after: i) }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (HTTPHeader, String)...) {
        self.init()
        
        for (header, value) in elements {
            self.addValue(value, for: header)
        }
    }
    
}
