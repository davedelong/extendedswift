//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/25/23.
//

import Foundation

internal class _PlistEncoder: Encoder {
    var codingPath: Array<CodingKey>
    var userInfo: Dictionary<CodingUserInfoKey, Any> { [:] }
    var parent: PlistWriter
    
    init(codingPath: Array<CodingKey>, parent: PlistWriter) {
        self.parent = parent
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = _PlistKeyedEncoder<Key>(codingPath: codingPath, parent: parent)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _PlistArrayEncoder(codingPath: codingPath, parent: parent)
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = _PlistValueEncoder(codingPath: codingPath, parent: parent)
        return container
    }
}

internal class _PlistKeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var codingPath: Array<CodingKey>
    var parent: PlistWriter
    
    init(codingPath: Array<CodingKey>, parent: PlistWriter) {
        self.codingPath = codingPath
        self.parent = parent
    }
    
    var contents = Dictionary<String, Any>() {
        didSet { parent.write(value: contents) }
    }
    
    func encodeNil(forKey key: Key) throws { contents[key.stringValue] = PlistNullValue }
    func encode(_ value: Bool, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: String, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Double, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Float, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Int, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Int8, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Int16, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Int32, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: Int64, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: UInt, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: UInt8, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: UInt16, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: UInt32, forKey key: Key) throws { contents[key.stringValue] = value }
    func encode(_ value: UInt64, forKey key: Key) throws { contents[key.stringValue] = value }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let writer = NestedKeyedWriter(parent: self, key: key)
        let path = self.codingPath + [key]
        let encoder = _PlistEncoder(codingPath: path, parent: writer)
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let writer = NestedKeyedWriter(parent: self, key: key)
        let path = self.codingPath + [key]
        let container = _PlistKeyedEncoder<NestedKey>(codingPath: path, parent: writer)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let writer = NestedKeyedWriter(parent: self, key: key)
        let path = self.codingPath + [key]
        let container = _PlistArrayEncoder(codingPath: path, parent: writer)
        return container
    }
    
    func superEncoder(forKey key: Key) -> Encoder { fatalError("no one uses this") }
    func superEncoder() -> Encoder { fatalError("no one uses this") }
       
}

internal class _PlistArrayEncoder: UnkeyedEncodingContainer {
    
    init(codingPath: Array<CodingKey>, parent: PlistWriter) {
        self.codingPath = codingPath
        self.parent = parent
    }
    
    var codingPath: Array<CodingKey>
    var parent: PlistWriter
    
    var count: Int { contents.count }
    
    var contents = Array<Any>() {
        didSet { parent.write(value: contents) }
    }
    
    func encodeNil() throws { contents.append(PlistNullValue) }
    func encode(_ value: Bool) throws { contents.append(value) }
    func encode(_ value: String) throws { contents.append(value) }
    func encode(_ value: Double) throws { contents.append(value) }
    func encode(_ value: Float) throws { contents.append(value) }
    func encode(_ value: Int) throws { contents.append(value) }
    func encode(_ value: Int8) throws { contents.append(value) }
    func encode(_ value: Int16) throws { contents.append(value) }
    func encode(_ value: Int32) throws { contents.append(value) }
    func encode(_ value: Int64) throws { contents.append(value) }
    func encode(_ value: UInt) throws { contents.append(value) }
    func encode(_ value: UInt8) throws { contents.append(value) }
    func encode(_ value: UInt16) throws { contents.append(value) }
    func encode(_ value: UInt32) throws { contents.append(value) }
    func encode(_ value: UInt64) throws { contents.append(value) }
    func encode<T>(_ value: T) throws where T : Encodable {
        let key = AnyCodingKey(intValue: self.contents.endIndex)!
        let writer = NestedUnkeyedWriter(parent: self, index: self.contents.endIndex)
        let path = self.codingPath + [key]
        let encoder = _PlistEncoder(codingPath: path, parent: writer)
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let key = AnyCodingKey(intValue: self.contents.endIndex)!
        let writer = NestedUnkeyedWriter(parent: self, index: self.contents.endIndex)
        let path = self.codingPath + [key]
        
        let container = _PlistKeyedEncoder<NestedKey>(codingPath: path, parent: writer)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let key = AnyCodingKey(intValue: self.contents.endIndex)!
        let writer = NestedUnkeyedWriter(parent: self, index: self.contents.endIndex)
        let path = self.codingPath + [key]
        let container = _PlistArrayEncoder(codingPath: path, parent: writer)
        return container
    }
    
    func superEncoder() -> Encoder { fatalError("no one uses this") }
    
}

internal struct _PlistValueEncoder: SingleValueEncodingContainer {
    var codingPath: Array<CodingKey>
    var parent: PlistWriter
    
    mutating func encodeNil() throws { parent.write(value: PlistNullValue) }
    mutating func encode(_ value: Bool) throws { parent.write(value: value) }
    mutating func encode(_ value: String) throws { parent.write(value: value) }
    mutating func encode(_ value: Double) throws { parent.write(value: value) }
    mutating func encode(_ value: Float) throws { parent.write(value: value) }
    mutating func encode(_ value: Int) throws { parent.write(value: value) }
    mutating func encode(_ value: Int8) throws { parent.write(value: value) }
    mutating func encode(_ value: Int16) throws { parent.write(value: value) }
    mutating func encode(_ value: Int32) throws { parent.write(value: value) }
    mutating func encode(_ value: Int64) throws { parent.write(value: value) }
    mutating func encode(_ value: UInt) throws { parent.write(value: value) }
    mutating func encode(_ value: UInt8) throws { parent.write(value: value) }
    mutating func encode(_ value: UInt16) throws { parent.write(value: value) }
    mutating func encode(_ value: UInt32) throws { parent.write(value: value) }
    mutating func encode(_ value: UInt64) throws { parent.write(value: value) }
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = _PlistEncoder(codingPath: codingPath, parent: parent)
        try value.encode(to: encoder)
    }
}

private struct NestedKeyedWriter<ParentKey: CodingKey, ChildKey: CodingKey>: PlistWriter {
    let parent: _PlistKeyedEncoder<ParentKey>
    let key: ChildKey
    
    func write(value: Any) { parent.contents[key.stringValue] = value }
}

private struct NestedUnkeyedWriter: PlistWriter {
    let parent: _PlistArrayEncoder
    let index: Int
    
    func write(value: Any) {
        if parent.contents.count == index {
            parent.contents.append(value)
        } else {
            parent.contents[index] = value
        }
    }
}
