//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import Algorithms

extension Collection {
    
    public func uniqued<V: Hashable>(by value: (Element) -> V) -> Array<Element> {
        return self.uniqued(on: value)
    }
    
}

extension Collection where Element: Hashable {
    
    public func uniqued() -> Array<Element> {
        return self.uniqued(by: { $0 })
    }
    
}
