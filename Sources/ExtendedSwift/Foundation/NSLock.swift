//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/8/23.
//

import Foundation

extension NSLocking {
    
    public func withLock<T>(_ perform: () -> T) -> T {
        self.lock()
        let result = perform()
        self.unlock()
        return result
    }
    
}

@propertyWrapper
public struct Locked<Value> {
    
    public struct Modifier {
        internal let lock: () -> Void
        internal let get: () -> Value
        internal let set: (Value) -> Void
        internal let unlock: () -> Void
        
        public func modify<T>(_ closure: (inout Value) -> T) -> T {
            lock()
            var value = get()
            let mapped = closure(&value)
            set(value)
            unlock()
            return mapped
        }
        
        public func callAsFunction<T>(_ closure: (inout Value) -> T) -> T {
            self.modify(closure)
        }
    }
    
    private var value: Value
    
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public var projectedValue: Modifier {
        get { fatalError() }
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public static subscript<EnclosingSelf: NSLocking>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            instance.lock()
            let value = instance[keyPath: storageKeyPath].value
            instance.unlock()
            return value
        }
        
        set {
            instance.lock()
            instance[keyPath: storageKeyPath].value = newValue
            instance.unlock()
        }
    }
    
    public static subscript<EnclosingSelf: NSLocking>(
        _enclosingInstance instance: EnclosingSelf,
        projected projectedKeyPath: KeyPath<EnclosingSelf, Modifier>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>) -> Modifier {
        
        get {
            return Modifier(lock: instance.lock,
                            get: { instance[keyPath: storageKeyPath].value },
                            set: { instance[keyPath: storageKeyPath].value = $0 },
                            unlock: instance.unlock)
        }
    }
}
