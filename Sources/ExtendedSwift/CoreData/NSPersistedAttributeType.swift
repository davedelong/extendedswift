//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/23.
//

import Foundation
import CoreData

public protocol NSPersistedAttributeType {
    static var attributeType: NSAttributeType { get }
    static var transformer: NSValueTransformerName? { get }
}

extension NSPersistedAttributeType {
    public static var transformer: NSValueTransformerName? { nil }
}

extension String: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .stringAttributeType }
}

extension Int: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .integer64AttributeType }
}

extension Int64: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .integer64AttributeType }
}

extension Int32: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .integer32AttributeType }
}

extension Int16: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .integer16AttributeType }
}

extension Decimal: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .decimalAttributeType }
}

extension Double: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .doubleAttributeType }
}

extension Float: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .floatAttributeType }
}

extension Bool: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .booleanAttributeType }
}

extension Date: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .dateAttributeType }
}

extension Data: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .binaryDataAttributeType }
}

extension UUID: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .UUIDAttributeType }
}

extension URL: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .URIAttributeType }
}

extension NSManagedObjectID: NSPersistedAttributeType {
    public static var attributeType: NSAttributeType { .objectIDAttributeType }
}
