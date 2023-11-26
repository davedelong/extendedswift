//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import CoreData

extension NSAttributeDescription {
    
    public static func int16(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .integer16AttributeType)
    }
    
    public static func int32(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .integer32AttributeType)
    }
    
    public static func int64(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .integer64AttributeType)
    }
    
    public static func decimal(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .decimalAttributeType)
    }
    
    public static func double(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .doubleAttributeType)
    }
    
    public static func string(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .stringAttributeType)
    }
    
    public static func bool(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .booleanAttributeType)
    }
    
    public static func date(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .dateAttributeType)
    }
    
    public static func data(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .binaryDataAttributeType)
    }
    
    public static func uuid(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .UUIDAttributeType)
    }
    
    public static func url(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .URIAttributeType)
    }
    
    public static func transformable(_ name: String, required: Bool = true) -> NSAttributeDescription {
        return NSAttributeDescription(name: name, optional: required == false, type: .transformableAttributeType)
    }
    
    public convenience init(name: String, optional: Bool, type: NSAttributeType) {
        self.init()
        self.name = name
        self.isOptional = optional
        self.attributeType = type
    }
    
}
