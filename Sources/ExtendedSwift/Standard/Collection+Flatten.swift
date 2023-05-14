//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/14/23.
//

import Foundation

extension Collection where Element: Collection {
    
    public func flattened() -> Array<Element.Element> {
        return self.flatMap { $0 }
    }
    
}
