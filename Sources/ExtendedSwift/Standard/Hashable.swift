//
//  Hashable.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/24/25.
//

extension Hasher {
    
    public mutating func combine<A: Hashable, B: Hashable, each V: Hashable>(_ a: A, _ b: B, _ others: repeat each V) {
        self.combine(a)
        self.combine(b)
        repeat self.combine(each others)
    }
    
}
