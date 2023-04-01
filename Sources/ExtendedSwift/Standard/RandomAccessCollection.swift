//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension RandomAccessCollection {
    
    public func pluck(indices: some Collection<Index>) -> Array<Element> {
        return indices.map { self[$0] }
    }
    
    public subscript(at position: Index) -> Element? {
        guard position < endIndex else { return nil }
        return self[position]
    }
    
}
