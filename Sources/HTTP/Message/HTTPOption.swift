public protocol HTTPOption {
    
    associatedtype Value: Sendable
    
    static var defaultValue: Value { get }
    
}

public struct HTTPOptions: Sendable {
    
    private var storage = [ObjectIdentifier: any Sendable]()
    
    public subscript<O: HTTPOption>(type: O.Type) -> O.Value {
        get {
            let id = ObjectIdentifier(type)
            if let override = storage[id] as? O.Value {
                return override
            }
            return O.defaultValue
        }
        set {
            let id = ObjectIdentifier(type)
            storage[id] = newValue
        }
    }
    
}
