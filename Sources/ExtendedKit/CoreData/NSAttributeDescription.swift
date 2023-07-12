//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import CoreData

extension NSAttributeDescription {
    
    public convenience init(name: String, optional: Bool, type: NSAttributeType) {
        self.init()
        self.name = name
        self.isOptional = optional
        self.attributeType = type
    }
    
}
