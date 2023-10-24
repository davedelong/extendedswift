//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/24/23.
//

#if canImport(CloudKit)

import Foundation
import CloudKit

// MARK: - CKRecord

public protocol CKRecordDecodable {
    init(from record: CKRecord) throws
}

public protocol CKRecordEncodable {
    var recordType: CKRecord.RecordType { get }
    
    func encode(to record: CKRecord?) throws -> CKRecord
}

public typealias CKRecordCodable = CKRecordDecodable & CKRecordEncodable

// MARK: - CKRecordValue

public protocol CKRecordValueDecodable {
    associatedtype RecordValue: CKRecordValueProtocol & Equatable
    init(recordValue value: RecordValue) throws
}

public protocol CKRecordValueEncodable {
    associatedtype RecordValue: CKRecordValueProtocol & Equatable
    func encodeToRecordValue() throws -> RecordValue
}

public typealias CKRecordValueCodable = CKRecordValueDecodable & CKRecordValueEncodable

public enum CKDecodingError: Error {
    case keyNotFound(String, CKRecord)
    case valueCorrupted(CKRecordValueProtocol, CKRecord?)
}

extension CKRecord {
    
    public func decode<V: CKRecordValueDecodable>(_ key: String) throws -> V {
        guard let raw: V.RecordValue = self[key] else { throw CKDecodingError.keyNotFound(key, self) }
        return try V(recordValue: raw)
    }
    
    public func decodeIfPresent<V: CKRecordValueDecodable>(_ key: String) throws -> V? {
        guard let raw: V.RecordValue = self[key] else { return nil }
        return try V(recordValue: raw)
    }
    
    public func encode<V: CKRecordValueEncodable>(_ value: V?, forKey key: String) throws {
        guard let unwrapped = value else { return }
        let raw: V.RecordValue = try unwrapped.encodeToRecordValue()
        
        // do not encode unchanged values, if they're present on this record
        if let existing: V.RecordValue = self[key], existing == raw { return }
        
        self[key] = raw
    }
}

///

extension CKRecord: CKRecordEncodable {
    public func encode(to record: CKRecord?) throws -> CKRecord {
        return self
    }
}

extension Array: CKRecordValueCodable where Element: CKRecordValueCodable {
    public init(recordValue value: Array<Element.RecordValue>) throws {
        self = try value.map { try Element(recordValue: $0) }
    }
    public func encodeToRecordValue() throws -> Array<Element.RecordValue> {
        try map { try $0.encodeToRecordValue() }
    }
}

extension CKRecordValueDecodable where RecordValue == Self {
    public init(recordValue value: Self) throws {
        self = value
    }
}

extension CKRecordValueDecodable where Self: RawRepresentable, RecordValue == RawValue, Self.RawValue: CKRecordValueEncodable {
    public init(recordValue value: RawValue) throws {
        if let v = Self(rawValue: value) {
            self = v
        } else {
            throw AnyError("Invalid rawValue for \(Self.self): \(value)")
        }
    }
}

extension CKRecordValueEncodable where RecordValue == Self {
    public func encodeToRecordValue() throws -> Self { self }
}

extension CKRecordValueEncodable where Self: RawRepresentable, RecordValue == RawValue, Self.RawValue: CKRecordValueEncodable {
    public func encodeToRecordValue() throws -> RecordValue { rawValue }
}

extension Bool: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension CKAsset: CKRecordValueCodable {
    public typealias RecordValue = CKAsset
}
extension CKRecord.Reference: CKRecordValueCodable {
    public typealias RecordValue = CKRecord.Reference
}
extension CLLocation: CKRecordValueCodable {
    public typealias RecordValue = CLLocation
}
extension Data: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Date: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Double: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Float: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Int: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Int16: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Int32: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Int64: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension Int8: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension NSArray: CKRecordValueCodable {
    public typealias RecordValue = NSArray
}
extension NSData: CKRecordValueCodable {
    public typealias RecordValue = NSData
}
extension NSDate: CKRecordValueCodable {
    public typealias RecordValue = NSDate
}
extension NSNumber: CKRecordValueCodable {
    public typealias RecordValue = NSNumber
}
extension NSString: CKRecordValueCodable {
    public typealias RecordValue = NSString
}
extension String: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension UInt: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension UInt16: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension UInt32: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension UInt64: CKRecordValueCodable {
    public typealias RecordValue = Self
}
extension UInt8: CKRecordValueCodable {
    public typealias RecordValue = Self
}

// CUSTOM

//extension Logger.Level: CKRecordValueCodable {
//    typealias RecordValue = RawValue
//}

extension URL: CKRecordValueCodable {
    public typealias RecordValue = String
    public init(recordValue value: String) throws {
        guard let u = URL(string: value) else {
            throw CKDecodingError.valueCorrupted(value, nil)
        }
        self = u
    }
    
    public func encodeToRecordValue() throws -> String {
        return self.absoluteString
    }
}

extension RawRepresentable where Self: CKRecordValueEncodable, RawValue: CKRecordValueEncodable {
    public func encodeToRecordValue() throws -> RawValue.RecordValue { try rawValue.encodeToRecordValue() }
}

extension RawRepresentable where Self: CKRecordValueDecodable, RawValue: CKRecordValueDecodable {
    public init(from value: RawValue.RecordValue) throws {
        let rawValue = try RawValue(recordValue: value)
        guard let v = Self(rawValue: rawValue) else {
            throw CKDecodingError.valueCorrupted(value, nil)
        }
        self = v
    }
}

#endif
