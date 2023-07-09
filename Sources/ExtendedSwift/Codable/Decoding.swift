//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Decoder {
    
    public func anyKeyedContainer() throws -> KeyedDecodingContainer<AnyCodingKey> {
        try self.container(keyedBy: AnyCodingKey.self)
    }
    
}

extension KeyedDecodingContainer {
    
    public func decode<T: Decodable>(_ key: Key) throws -> T {
        return try self.decode(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T: Decodable>(_ key: Key) throws -> T? {
        return try self.decodeIfPresent(T.self, forKey: key)
    }
    
    public subscript<T: Decodable>(key: Key) -> T {
        get throws { try self.decode(T.self, forKey: key) }
    }
    
    public subscript<T: Decodable>(ifPresent key: Key) -> T? {
        get throws { try self.decodeIfPresent(T.self, forKey: key) }
    }
    
    public subscript<T: Decodable & RangeReplaceableCollection>(orEmpty key: Key) -> T {
        get throws { try self.decodeIfPresent(T.self, forKey: key) ?? T.init() }
    }
    
    public subscript<T: Decodable & Collection>(ifNotEmpty key: Key) -> T? {
        get throws {
            let collection = try self.decodeIfPresent(T.self, forKey: key)
            if collection?.isEmpty == false { return collection }
            return nil
        }
    }
    
    public subscript<T: Decodable>(key: Key, default value: @autoclosure () -> T) -> T {
        get throws { try self.decodeIfPresent(T.self, forKey: key) ?? value() }
    }
    
    public subscript<T: Decodable>(key: Key, failWith value: @autoclosure () -> T) -> T {
        do {
            return try self.decode(T.self, forKey: key)
        } catch {
            assertionFailure("Could not decode \(key): \(error)")
            return value()
        }
    }
    
    public subscript<T: Decodable & RangeReplaceableCollection>(compactingErrors key: Key) -> T where T.Element: Decodable {
        guard contains(key) else { return .init() }
        do {
            var container = try nestedUnkeyedContainer(forKey: key)
            return container.decodeCompactingErrors()
        } catch {
            assertionFailure("Could not decode \(key): \(error)")
            return .init()
        }
    }
}

extension UnkeyedDecodingContainer {
    
    public mutating func decodeCompactingErrors<T: Decodable & RangeReplaceableCollection>(_ type: T.Type = T.self) -> T where T.Element: Decodable {
        var final = T()
        while isAtEnd == false {
            do {
                final.append(try self.decode(T.Element.self))
            } catch {
                assertionFailure("Could not decode \(T.Element.self): \(error)")
            }
        }
        return final
    }
    
    public mutating func decodeIfNotEmpty<T: Decodable & Collection>(_ type: T.Type = T.self) throws -> T? {
        guard let collection = try self.decodeIfPresent(type) else { return nil }
        return collection.isEmpty ? nil : collection
    }
    
    public mutating func map<T>(_ transform: (Decoder) throws -> T) throws -> Array<T> {
        var final = Array<T>()
        while isAtEnd == false {
            let childDecoder = try superDecoder()
            let element = try transform(childDecoder)
            final.append(element)
        }
        return final
    }
    
    public mutating func compactMap<T>(_ transform: (Decoder) throws -> T?) throws -> Array<T> {
        var final = Array<T>()
        while isAtEnd == false {
            let childDecoder = try superDecoder()
            if let element = try transform(childDecoder) {
                final.append(element)
            }
        }
        return final
    }
    
}

