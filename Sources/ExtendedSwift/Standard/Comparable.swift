//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation


extension Comparable {
    
    public func compare(_ other: Self) -> ComparisonResult {
        if self < other { return .orderedAscending }
        if self == other { return .orderedSame }
        return .orderedDescending
    }
    
}

extension Collection {
    
    public func sorted<V: Comparable>(by value: (Element) -> V) -> Array<Element> {
        return sorted(by: {
            value($0) < value($1)
        })
    }
    
    public func max<C: Comparable>(of property: (Element) -> C) -> C? {
        return self.lazy.map(property).max()
    }
    
    public func min<C: Comparable>(of property: (Element) -> C) -> C? {
        return self.lazy.map(property).min()
    }
    
    public func max<C: Comparable>(by property: (Element) -> C) -> Element? {
        return self.max(by: { (l, r) -> Bool in
            let lValue = property(l)
            let rValue = property(r)
            return lValue < rValue
        })
    }
    
    public func min<C: Comparable>(by property: (Element) -> C) -> Element? {
        return self.min(by: { (l, r) -> Bool in
            let lValue = property(l)
            let rValue = property(r)
            return lValue < rValue
        })
    }
    
    public func range<C: Comparable>(of value: (Element) -> C) -> ClosedRange<C>? {
        guard isNotEmpty else { return nil }
        
        let firstValue = value(self[startIndex])
        var range = firstValue ... firstValue
        
        for index in self.indices.dropFirst() {
            let itemValue = value(self[index])
            if itemValue < range.lowerBound { range = itemValue ... range.upperBound }
            if itemValue > range.upperBound { range = range.lowerBound ... itemValue }
        }
        return range
    }
    
}

extension Collection where Element: Comparable {
    
    public var max: Element? {
        return self.max(by: { $0 })
    }
    
    public var min: Element? {
        return self.min(by: { $0 })
    }
    
    public var range: ClosedRange<Element>? {
        return self.range(of: { $0 })
    }
    
}
