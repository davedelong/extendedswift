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

protocol CKRecordValueDecodable {
    associatedtype RecordValue: CKRecordValueProtocol & Equatable
    init(recordValue value: RecordValue) throws
}

protocol CKRecordValueEncodable {
    associatedtype RecordValue: CKRecordValueProtocol & Equatable
    func encodeToRecordValue() throws -> RecordValue
}

typealias CKRecordValueCodable = CKRecordValueDecodable & CKRecordValueEncodable

public enum CKDecodingError: Error {
    case keyNotFound(String, CKRecord)
    case valueCorrupted(CKRecordValueProtocol, CKRecord?)
}

extension CKRecord {
    
    func decode<V: CKRecordValueDecodable>(_ key: String) throws -> V {
        guard let raw: V.RecordValue = self[key] else { throw CKDecodingError.keyNotFound(key, self) }
        return try V(recordValue: raw)
    }
    
    func decodeIfPresent<V: CKRecordValueDecodable>(_ key: String) throws -> V? {
        guard let raw: V.RecordValue = self[key] else { return nil }
        return try V(recordValue: raw)
    }
    
    func encode<V: CKRecordValueEncodable>(_ value: V?, forKey key: String) throws {
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
    init(recordValue value: Array<Element.RecordValue>) throws {
        self = try value.map { try Element(recordValue: $0) }
    }
    func encodeToRecordValue() throws -> Array<Element.RecordValue> {
        try map { try $0.encodeToRecordValue() }
    }
}

extension CKRecordValueDecodable where RecordValue == Self {
    init(recordValue value: Self) throws {
        self = value
    }
}

extension CKRecordValueDecodable where Self: RawRepresentable, RecordValue == RawValue, Self.RawValue: CKRecordValueEncodable {
    init(recordValue value: RawValue) throws {
        if let v = Self(rawValue: value) {
            self = v
        } else {
            throw AnyError("Invalid rawValue for \(Self.self): \(value)")
        }
    }
}

extension CKRecordValueEncodable where RecordValue == Self {
    func encodeToRecordValue() throws -> Self { self }
}

extension CKRecordValueEncodable where Self: RawRepresentable, RecordValue == RawValue, Self.RawValue: CKRecordValueEncodable {
    func encodeToRecordValue() throws -> RecordValue { rawValue }
}

extension Bool: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension CKAsset: CKRecordValueCodable {
    typealias RecordValue = CKAsset
}
extension CKRecord.Reference: CKRecordValueCodable {
    typealias RecordValue = CKRecord.Reference
}
extension CLLocation: CKRecordValueCodable {
    typealias RecordValue = CLLocation
}
extension Data: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Date: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Double: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Float: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Int: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Int16: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Int32: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Int64: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension Int8: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension NSArray: CKRecordValueCodable {
    typealias RecordValue = NSArray
}
extension NSData: CKRecordValueCodable {
    typealias RecordValue = NSData
}
extension NSDate: CKRecordValueCodable {
    typealias RecordValue = NSDate
}
extension NSNumber: CKRecordValueCodable {
    typealias RecordValue = NSNumber
}
extension NSString: CKRecordValueCodable {
    typealias RecordValue = NSString
}
extension String: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension UInt: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension UInt16: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension UInt32: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension UInt64: CKRecordValueCodable {
    typealias RecordValue = Self
}
extension UInt8: CKRecordValueCodable {
    typealias RecordValue = Self
}

// CUSTOM

//extension Logger.Level: CKRecordValueCodable {
//    typealias RecordValue = RawValue
//}

extension URL: CKRecordValueCodable {
    typealias RecordValue = String
    init(recordValue value: String) throws {
        guard let u = URL(string: value) else {
            throw CKDecodingError.valueCorrupted(value, nil)
        }
        self = u
    }
    
    func encodeToRecordValue() throws -> String {
        return self.absoluteString
    }
}

extension RawRepresentable where Self: CKRecordValueEncodable, RawValue: CKRecordValueEncodable {
    func encodeToRecordValue() throws -> RawValue.RecordValue { try rawValue.encodeToRecordValue() }
}

extension RawRepresentable where Self: CKRecordValueDecodable, RawValue: CKRecordValueDecodable {
    init(from value: RawValue.RecordValue) throws {
        let rawValue = try RawValue(recordValue: value)
        guard let v = Self(rawValue: rawValue) else {
            throw CKDecodingError.valueCorrupted(value, nil)
        }
        self = v
    }
}

#endif
