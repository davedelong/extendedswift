//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/16/23.
//

import Foundation
import CoreData

extension NSEntityDescription {
    
    public convenience init(_ name: String, properties: Array<NSPropertyDescription>) {
        self.init()
        self.name = name
        self.properties = properties
    }
    
}
