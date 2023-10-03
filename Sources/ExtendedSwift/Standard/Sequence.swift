//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/3/23.
//

import Foundation

extension Sequence {
    
    public func firstMap<Output>(_ mapper: (Element) -> Output?) -> Output? {
        for item in self {
            if let m = mapper(item) { return m }
        }
        return nil
    }
    
}
