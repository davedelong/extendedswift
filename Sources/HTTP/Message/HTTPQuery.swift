public struct HTTPQuery: Sendable, Collection {
    
    private var pairs = Pairs<String, String>()
    
    public init() { }
    
    public subscript(name: String) -> [String] {
        get { pairs[name] }
        set { pairs[name] = newValue }
    }
    
    public func firstValue(for name: String) -> String? {
        pairs.firstValue(for: name)
    }
    
    public mutating func setValue(_ value: String?, for name: String) {
        pairs.setValue(value, for: name)
    }
    
    public mutating func addValue(_ value: String, for name: String) {
        pairs.addValue(value, for: name)
    }
    
    public typealias Element = (String, String)
    
    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return pairs.makeIterator()
    }
    
    public var count: Int { pairs.count }
    public var startIndex: Int { pairs.startIndex }
    public var endIndex: Int { pairs.endIndex }
    public subscript(position: Int) -> Element { pairs[position] }
    public func index(after i: Int) -> Int { pairs.index(after: i) }
    
}

extension HTTPQuery: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
    public init(arrayLiteral elements: Element...) {
        self.init()
        for (key, value) in elements {
            self.addValue(value, for: key)
        }
    }
    
    public init(dictionaryLiteral elements: Element...) {
        self.init()
        for (key, value) in elements {
            self.addValue(value, for: key)
        }
    }
    
}
