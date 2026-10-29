//
//  EntryContainer.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 10/29/26.
//

import Foundation

public protocol EntryContainer {
    func get<K: EntryContainerKey>(_ key: K.Type) throws -> K.Value where K.Container == Self
    func set<K: EntryContainerKey>(_ key: K.Type, value: K.Value) throws where K.Container == Self
}

extension EntryContainer {
    public func get<K: EntryContainerKey>(_ key: K.Type) throws -> K.Value where K.Container == Self {
        return try K.read(from: self)
    }
    
    public func set<K: EntryContainerKey>(_ key: K.Type, value: K.Value) throws where K.Container == Self {
        try K.write(to: self, value: value)
    }
}

public protocol EntryContainerKey<Container> {
    associatedtype Container: EntryContainer
    associatedtype Value
    
    static nonisolated var defaultValue: Value { get }
    
    static func read(from container: Container) throws -> Value
    static func write(to container: Container, value: Value) throws
}

// MARK: - UserDefaults

public protocol UserDefaultsKey: EntryContainerKey where Container == UserDefaults, Value: Codable {
    static nonisolated var rawKey: String { get }
}

extension UserDefaults: EntryContainer {
    public func get<K: UserDefaultsKey>(_ key: K.Type) -> K.Value {
        do {
            return try K.read(from: self)
        } catch {
            print("Error reading \(K.rawKey): \(error)")
            return K.defaultValue
        }
    }
    public func set<K: UserDefaultsKey>(_ key: K.Type, _ value: K.Value) {
        do {
            try K.write(to: self, value: value)
        } catch {
            print("Error writing \(K.rawKey): \(error)")
        }
    }
}

extension UserDefaultsKey {
    public static func read(from container: Container) throws -> Value {
        if let existing = container.object(forKey: self.rawKey) {
            return try PlistDecoder().decode(Value.self, from: existing)
        } else {
            return self.defaultValue
        }
    }
    
    public static func write(to container: Container, value: Value) throws  {
        let encoded = try PlistEncoder().encode(value)
        container.set(encoded, forKey: self.rawKey)
    }
}
