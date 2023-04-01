//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Collection {
    
    public var isNotEmpty: Bool { isEmpty == false }
    
    public var firstIndex: Index? {
        guard isNotEmpty else { return nil }
        return startIndex
    }
    
    public func allPrefixes() -> Array<SubSequence> {
        return indices.map { self[startIndex ... $0] }
    }
    
    public func count(where matches: (Element) -> Bool) -> Int {
        var i = 0
        for item in self {
            i += matches(item) ? 1 : 0
        }
        return i
    }
    
    public func compacted<Value>() -> Array<Value> where Element == Optional<Value> {
        return compactMap { $0 }
    }
    
    public func filter<T>(is type: T.Type) -> Array<T> {
        return compactMap { $0 as? T }
    }
    
    public func filter<T>(isNot type: T.Type) -> Array<Element> {
        return compactMap { $0 is T ? nil : $0 }
    }
    
    public func keyed<Key: Hashable>(by keyer: (Element) -> Key) -> Dictionary<Key, Element> {
        var final = Dictionary<Key, Element>()
        for item in self {
            let key = keyer(item)
            final[key] = item
        }
        return final
    }
    
    public func keyed<Key: Hashable>(by keyer: (Element) -> Key?) -> Dictionary<Key, Element> {
        var final = Dictionary<Key, Element>()
        for item in self {
            guard let key = keyer(item) else { continue }
            final[key] = item
        }
        return final
    }
    
    public func grouped<Key: Hashable>(by keyer: (Element) -> Key) -> Dictionary<Key, [Element]> {
        var final = Dictionary<Key, [Element]>()
        for item in self {
            let key = keyer(item)
            final[key, default: []].append(item)
        }
        return final
    }
    
    public func grouped<Key: Hashable>(by keyer: (Element) -> Key?) -> Dictionary<Key, [Element]> {
        var final = Dictionary<Key, [Element]>()
        for item in self {
            guard let key = keyer(item) else { continue }
            final[key, default: []].append(item)
        }
        return final
    }
    
    public func divide(by belongsInFirst: (Element) -> Bool) -> (first: Array<Element>, second: Array<Element>) {
        var first = Array<Element>()
        var second = Array<Element>()
        
        for item in self {
            if belongsInFirst(item) {
                first.append(item)
            } else {
                second.append(item)
            }
        }
        return (first, second)
    }
    
    public func anySatisfy(_ predicate: (Element) -> Bool) -> Bool {
        return contains(where: predicate)
    }
    
    public func noneSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        return anySatisfy(predicate) == false
    }
    
}

extension Collection {
    
    func sum<N: Numeric>(of value: (Element) -> N) -> N? {
        guard isNotEmpty else { return nil }
        return reduce(into: N.zero) { $0 += value($1) }
    }
    
    func product<N: Numeric>(of value: (Element) -> N) -> N? {
        guard isNotEmpty else { return nil }
        return reduce(into: (1 as N)) { $0 *= value($1) }
    }
    
}

extension Collection where Element: Numeric {
    
    func sum() -> Element? {
        return self.sum(of: { $0 })
    }
    
    func product() -> Element? {
        return self.product(of: { $0 })
    }
    
}
