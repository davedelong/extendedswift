//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/25/23.
//

import Foundation

internal class _PlistDecoder: Decoder {
    var codingPath: Array<CodingKey>
    let contents: Any
    
    var userInfo: Dictionary<CodingUserInfoKey, Any> { [:] }
    
    init(codingPath: Array<CodingKey>, contents: Any) {
        self.codingPath = codingPath
        self.contents = contents
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let inner = try contents as? Dictionary<String, Any> ?! decodingError.dataCorrupted("Not a dictionary")
        let container = _PlistKeyedDecoder<Key>(codingPath: codingPath, contents: inner)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let inner = try contents as? Array<Any> ?! decodingError.dataCorrupted("Not an array")
        let container = _PlistArrayDecoder(codingPath: codingPath, contents: inner)
        return container
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _PlistValueDecoder(codingPath: codingPath, contents: contents)
    }
    
}

internal class _PlistKeyedDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    var codingPath: Array<CodingKey>
    let contents: Dictionary<String, Any>
    
    init(codingPath: Array<CodingKey>, contents: Dictionary<String, Any>) {
        self.codingPath = codingPath
        self.contents = contents
    }
    
    var allKeys: Array<Key> { contents.keys.compactMap { Key(stringValue: $0) } }
    
    private func read<T>(key: Key, type: T.Type = T.self) throws -> T {
        guard let value = contents[key.stringValue] else {
            throw decodingError.keyNotFound(key)
        }
        guard let typed = value as? T else {
            throw decodingError.dataCorrupted(for: key, "Value is not a \(T.self)")
        }
        return typed
    }
    
    private func readIfPresent<T>(key: Key, type: T.Type = T.self) throws -> T? {
        guard let value = contents[key.stringValue] else {
            return nil
        }
        if let sentinel = value as? String, sentinel == PlistNullValue {
            return nil
        }
        guard let typed = value as? T else {
            throw decodingError.dataCorrupted(for: key, "Value is not a \(T.self)")
        }
        return typed
    }
    
    func contains(_ key: Key) -> Bool { contents.keys.contains(key.stringValue) }
    func decodeNil(forKey key: Key) throws -> Bool {
        let sentinel = try read(key: key, type: String.self)
        guard sentinel == PlistNullValue else {
            throw decodingError.dataCorrupted(for: key, "Wrong sentinel value")
        }
        return true
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try read(key: key) }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { try read(key: key) }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try read(key: key) }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try read(key: key) }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { try read(key: key) }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try read(key: key) }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try read(key: key) }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try read(key: key) }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try read(key: key) }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { try read(key: key) }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try read(key: key) }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try read(key: key) }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try read(key: key) }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try read(key: key) }
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let any = try read(key: key, type: Any.self)
        let inner = _PlistDecoder(codingPath: codingPath + [key], contents: any)
        return try T.init(from: inner)
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? { try readIfPresent(key: key) }
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? { try readIfPresent(key: key) }
    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        guard let any = try readIfPresent(key: key, type: Any.self) else { return nil }
        let inner = _PlistDecoder(codingPath: codingPath + [key], contents: any)
        return try T.init(from: inner)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let innerContents = try read(key: key, type: Dictionary<String, Any>.self)
        let container = _PlistKeyedDecoder<NestedKey>(codingPath: codingPath + [key], contents: innerContents)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let innerContents = try read(key: key, type: Array<Any>.self)
        let container = _PlistArrayDecoder(codingPath: codingPath + [key], contents: innerContents)
        return container
    }
    
    func superDecoder() throws -> Decoder { fatalError("no one uses this") }
    func superDecoder(forKey key: Key) throws -> Decoder { fatalError("no one uses this") }
    
}

internal class _PlistArrayDecoder: UnkeyedDecodingContainer {
    
    let codingPath: Array<CodingKey>
    let contents: Array<Any>
    var currentIndex = 0
    var count: Int? { contents.count }
    var isAtEnd: Bool { currentIndex >= contents.endIndex }
    
    init(codingPath: Array<CodingKey>, contents: Array<Any>) {
        self.codingPath = codingPath
        self.contents = contents
    }
    
    private func read<T>(type: T.Type = T.self) throws -> T {
        guard isAtEnd == false else {
            throw decodingError.valueNotFound(T.self, "No more values")
        }
        let value = contents[currentIndex]
        currentIndex += 1
        
        guard let typed = value as? T else {
            throw decodingError.typeMismatch(T.self, "Value is not a \(T.self)")
        }
        return typed
    }
    
    private func readIfPresent<T>(type: T.Type = T.self) throws -> T? {
        guard isAtEnd == false else {
            return nil
        }
        let value = contents[currentIndex]
        currentIndex += 1
        
        if let sentinel = value as? String, sentinel == PlistNullValue {
            return nil
        }
        
        guard let typed = value as? T else {
            throw decodingError.typeMismatch(T.self, "Value is not a \(T.self)")
        }
        return typed
    }
    
    func decodeNil() throws -> Bool {
        let str = try read(type: String.self)
        return str == PlistNullValue
    }
    func decode(_ type: Bool.Type) throws -> Bool { try read() }
    func decode(_ type: String.Type) throws -> String { try read() }
    func decode(_ type: Double.Type) throws -> Double { try read() }
    func decode(_ type: Float.Type) throws -> Float { try read() }
    func decode(_ type: Int.Type) throws -> Int { try read() }
    func decode(_ type: Int8.Type) throws -> Int8 { try read() }
    func decode(_ type: Int16.Type) throws -> Int16 { try read() }
    func decode(_ type: Int32.Type) throws -> Int32 { try read() }
    func decode(_ type: Int64.Type) throws -> Int64 { try read() }
    func decode(_ type: UInt.Type) throws -> UInt { try read() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try read() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try read() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try read() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try read() }
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let innerContents = try read(type: Any.self)
        let decoder = _PlistDecoder(codingPath: codingPath + [AnyCodingKey(intValue: currentIndex - 1)!], contents: innerContents)
        return try T.init(from: decoder)
    }
    
    func decodeIfPresent(_ type: Bool.Type) throws -> Bool? { try readIfPresent() }
    func decodeIfPresent(_ type: String.Type) throws -> String? { try readIfPresent() }
    func decodeIfPresent(_ type: Double.Type) throws -> Double? { try readIfPresent() }
    func decodeIfPresent(_ type: Float.Type) throws -> Float? { try readIfPresent() }
    func decodeIfPresent(_ type: Int.Type) throws -> Int? { try readIfPresent() }
    func decodeIfPresent(_ type: Int8.Type) throws -> Int8? { try readIfPresent() }
    func decodeIfPresent(_ type: Int16.Type) throws -> Int16? { try readIfPresent() }
    func decodeIfPresent(_ type: Int32.Type) throws -> Int32? { try readIfPresent() }
    func decodeIfPresent(_ type: Int64.Type) throws -> Int64? { try readIfPresent() }
    func decodeIfPresent(_ type: UInt.Type) throws -> UInt? { try readIfPresent() }
    func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? { try readIfPresent() }
    func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? { try readIfPresent() }
    func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? { try readIfPresent() }
    func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? { try readIfPresent() }
    func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T : Decodable {
        guard let innerContents = try readIfPresent(type: Any.self) else { return nil }
        let decoder = _PlistDecoder(codingPath: codingPath + [AnyCodingKey(intValue: currentIndex - 1)!], contents: innerContents)
        return try T.init(from: decoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let innerContents = try read(type: Dictionary<String, Any>.self)
        let container = _PlistKeyedDecoder<NestedKey>(codingPath: codingPath + [AnyCodingKey(intValue: currentIndex - 1)!], contents: innerContents)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let innerContents = try read(type: Array<Any>.self)
        let container = _PlistArrayDecoder(codingPath: codingPath + [AnyCodingKey(intValue: currentIndex - 1)!], contents: innerContents)
        return container
    }
    
    func superDecoder() throws -> Decoder { fatalError("no one uses this") }
}

internal class _PlistValueDecoder: SingleValueDecodingContainer {
    let codingPath: Array<CodingKey>
    let contents: Any
    
    init(codingPath: Array<CodingKey>, contents: Any) {
        self.codingPath = codingPath
        self.contents = contents
    }
    
    private func read<T>(type: T.Type = T.self) throws -> T {
        guard let typed = contents as? T else {
            throw decodingError.typeMismatch(T.self, "Value is not a \(T.self)")
        }
        return typed
    }
    
    func decodeNil() -> Bool {
        let sentinel = try? read(type: String.self)
        return sentinel == PlistNullValue
    }
    
    func decode(_ type: Bool.Type) throws -> Bool { try read() }
    func decode(_ type: String.Type) throws -> String { try read() }
    func decode(_ type: Double.Type) throws -> Double { try read() }
    func decode(_ type: Float.Type) throws -> Float { try read() }
    func decode(_ type: Int.Type) throws -> Int { try read() }
    func decode(_ type: Int8.Type) throws -> Int8 { try read() }
    func decode(_ type: Int16.Type) throws -> Int16 { try read() }
    func decode(_ type: Int32.Type) throws -> Int32 { try read() }
    func decode(_ type: Int64.Type) throws -> Int64 { try read() }
    func decode(_ type: UInt.Type) throws -> UInt { try read() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try read() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try read() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try read() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try read() }
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _PlistDecoder(codingPath: codingPath, contents: contents)
        return try T.init(from: decoder)
    }
    
}
