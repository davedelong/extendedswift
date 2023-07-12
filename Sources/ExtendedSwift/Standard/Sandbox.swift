//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation

public protocol SandboxProperty {
    associatedtype PropertyValue
    
    static func provideValue(for sandbox: Sandbox) -> PropertyValue
}

public class Sandbox {
    
    private let lock = NSRecursiveLock()
    private var values = Dictionary<ObjectIdentifier, Any>()
    
    public subscript<S: SandboxProperty>(key: S.Type) -> S.PropertyValue {
        get {
            return lock.withLock {
                let id = ObjectIdentifier(key)
                if let exisiting = values[id] as? S.PropertyValue {
                    return exisiting
                } else {
                    let newValue = S.provideValue(for: self)
                    values[id] = newValue
                    return newValue
                }
            }
        }
        set {
            lock.withLock {
                values[ObjectIdentifier(key)] = newValue
            }
        }
    }
    
    public func existingValue<S: SandboxProperty>(for property: S.Type) -> S.PropertyValue? {
        return lock.withLock {
            values[ObjectIdentifier(property)] as? S.PropertyValue
        }
    }
    
    public func hasProperty<S: SandboxProperty>(_ property: S.Type) -> Bool {
        return existingValue(for: property) != nil
    }
    
    public let groupIdentifier: String?
    
    public init(groupIdentifier: String?) {
        self.groupIdentifier = groupIdentifier
    }
    
}

extension Sandbox {
    
    public var documentsPath: AbsolutePath {
        get { self[DocumentsProperty.self] }
        set { self[DocumentsProperty.self] = newValue }
    }
    
    public var cachesPath: AbsolutePath {
        get { self[CachesProperty.self] }
        set { self[CachesProperty.self] = newValue }
    }
    
    public var supportPath: AbsolutePath {
        get { self[SupportProperty.self] }
        set { self[SupportProperty.self] = newValue }
    }
    
    public var temporaryPath: AbsolutePath {
        get { self[TemporaryProperty.self] }
        set { self[TemporaryProperty.self] = newValue }
    }
    
    public var logsPath: AbsolutePath {
        get { self[LogsProperty.self] }
        set { self[LogsProperty.self] = newValue }
    }
    
    public var userDefaults: UserDefaults {
        get { self[UserDefaultsProperty.self] }
        set { self[UserDefaultsProperty.self] = newValue }
    }
    
}

// MARK: - Default properties

private struct DocumentsProperty: SandboxProperty {
    
    static func provideValue(for sandbox: Sandbox) -> AbsolutePath {
        if let group = sandbox.groupIdentifier, let container = FileManager.default.containerPath(for: group) {
            let path = container.appending(component: "Documents")
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            return path
        } else {
            return try! FileManager.default.path(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
    }
    
}

private struct CachesProperty: SandboxProperty {
    
    static func provideValue(for sandbox: Sandbox) -> AbsolutePath {
        let path: AbsolutePath
        if let group = sandbox.groupIdentifier, let container = FileManager.default.containerPath(for: group) {
            path = container.appending(component: "Caches")
        } else {
            path = try! FileManager.default.path(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        path.isIncludedInBackup = false
        return path
    }
    
}

private struct SupportProperty: SandboxProperty {
    
    static func provideValue(for sandbox: Sandbox) -> AbsolutePath {
        if let group = sandbox.groupIdentifier, let container = FileManager.default.containerPath(for: group) {
            let path = container.appending(component: "Application Support")
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            return path
        } else {
            return try! FileManager.default.path(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
    }
    
}

private struct TemporaryProperty: SandboxProperty {
    static func provideValue(for sandbox: Sandbox) -> AbsolutePath {
        return AbsolutePath(fileSystemPath: NSTemporaryDirectory())
    }
}

private struct LogsProperty: SandboxProperty {
    static func provideValue(for sandbox: Sandbox) -> AbsolutePath {
        let path = sandbox.supportPath.appending(component: "Logs")
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        return path
    }
}

private struct UserDefaultsProperty: SandboxProperty {
    static func provideValue(for sandbox: Sandbox) -> UserDefaults {
        if let group = sandbox.groupIdentifier, let defaults = UserDefaults(suiteName: group) {
            return defaults
        }
        return .standard
    }
}
