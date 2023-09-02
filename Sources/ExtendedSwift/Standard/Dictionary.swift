//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Dictionary {
    
    public func mapKeys<NewKey: Hashable>(_ mapper: (Key) -> NewKey) -> Dictionary<NewKey, Value> {
        var f = Dictionary<NewKey, Value>()
        for (key, value) in self {
            f[mapper(key)] = value
        }
        return f
    }
    
    public func compactMapKeys<NewKey: Hashable>(_ mapper: (Key) -> NewKey?) -> Dictionary<NewKey, Value> {
        var f = Dictionary<NewKey, Value>()
        for (key, value) in self {
            if let newKey = mapper(key) {
                f[newKey] = value
            }
        }
        return f
    }
    
    public func flatMapKeys<Keys: Sequence>(_ mapper: (Key) -> Keys) -> Dictionary<Keys.Element, Value> where Keys.Element: Hashable {
        var f = Dictionary<Keys.Element, Value>()
        for (key, value) in self {
            let newKeys = mapper(key)
            for newKey in newKeys {
                f[newKey] = value
            }
        }
        return f
    }
    
    @discardableResult
    public mutating func removeValues<C: Collection>(forKeys keysToRemove: C) -> Dictionary<Key, Value> where C.Element == Key {
        var final = Dictionary<Key, Value>()
        for key in keysToRemove {
            if let value = removeValue(forKey: key) {
                final[key] = value
            }
        }
        return final
    }
    
    public mutating func removeKeys(where predicate: (Key) -> Bool) {
        for key in keys {
            if predicate(key) == true {
                removeValue(forKey: key)
            }
        }
    }
    
    public mutating func removeValues(where predicate: (Value) -> Bool) {
        for (key, value) in self {
            if predicate(value) == true {
                removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: Key, inserting value: @autoclosure () -> Value) -> Value {
        mutating get {
            if let e = self[key] { return e }
            let newValue = value()
            self[key] = newValue
            return newValue
        }
    }
    
}
