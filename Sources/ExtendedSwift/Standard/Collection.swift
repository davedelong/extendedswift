//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import Algorithms

extension Collection {
    
    public var isNotEmpty: Bool { isEmpty == false }
    
    public var firstIndex: Index? { self.indices.first }
    
    public var indexRange: Range<Index> { self.startIndex ..< self.endIndex }
    
    public func nilIfEmpty() -> Self? {
        if isEmpty { return nil }
        return self
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
    
    public func filter<T>(is type: T.Type) -> Array<T> {
        return compactMap { $0 as? T }
    }
    
    public func filter<T>(isNot type: T.Type) -> Array<Element> {
        return compactMap { $0 is T ? nil : $0 }
    }
    
    public func filter(id: Element.ID) -> Array<Element> where Element: Identifiable {
        return filter { $0.id == id }
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
    
    public func pairs() -> some Sequence<(Element, Element)> {
        return sequence(state: makeIterator(), next: { iterator in
            guard let a = iterator.next() else { return nil }
            guard let b = iterator.next() else { return nil }
            return (a, b)
        })
    }
    
    public func pluck(indices: some Collection<Index>) -> Array<Element> {
        return indices.map { self[$0] }
    }
    
    public subscript(at position: Index) -> Element? {
        guard position < endIndex else { return nil }
        return self[position]
    }
    
    public subscript(offset value: Int) -> Element? {
        let i = self.index(self.startIndex, offsetBy: value)
        if i >= self.endIndex { return nil }
        if i < self.startIndex { return nil }
        return self[i]
    }
    
    public func paddingPrefix(toLength: Int, with element: Element) -> Array<Element> {
        let neededLength = toLength - self.count
        if neededLength <= 0 { return Array(self) }
        return Array(repeating: element, count: neededLength) + Array(self)
    }
    
    public func paddingSuffix(toLength: Int, with element: Element) -> Array<Element> {
        let neededLength = toLength - self.count
        if neededLength <= 0 { return Array(self) }
        return Array(self) + Array(repeating: element, count: neededLength)
    }
    
    public func offset(of index: Index) -> Int {
        return self.distance(from: startIndex, to: index)
    }
}

extension Collection {
    
    public func sum<N: Numeric>(of value: (Element) -> N) -> N? {
        guard isNotEmpty else { return nil }
        return reduce(into: N.zero) { $0 += value($1) }
    }
    
    public func product<N: Numeric>(of value: (Element) -> N) -> N? {
        guard isNotEmpty else { return nil }
        return reduce(into: (1 as N)) { $0 *= value($1) }
    }
    
}

extension Collection where Element: Numeric {
    
    public var sum: Element? {
        return self.sum(of: { $0 })
    }
    
    public var product: Element? {
        return self.product(of: { $0 })
    }
    
}

extension Collection where Element: Equatable {
    
    public func count(of element: Element) -> Int {
        return self.count(where: { $0 == element })
    }
    
}

extension Array {
    
    public mutating func filterInPlace(_ including: (Element) -> Bool) {
        self = self.filter(including)
    }
    
}
