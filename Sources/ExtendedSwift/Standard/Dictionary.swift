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
    
}
