//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Collection {
    
    public func uniqued<V: Hashable>(by value: (Element) -> V) -> Array<Element> {
        var final = Array<Element>()
        var seen = Set<V>()
        
        for element in self {
            let id = value(element)
            if seen.contains(id) == false {
                seen.insert(id)
                final.append(element)
            }
        }
        
        return final
    }
    
}

extension Collection where Element: Hashable {
    
    public func uniqued() -> Array<Element> {
        return self.uniqued(by: { $0 })
    }
    
}
