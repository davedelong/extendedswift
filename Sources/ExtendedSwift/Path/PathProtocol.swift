//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

public let PathSeparator = "/"

public enum PathComponent: Hashable, Sendable {
    case this
    case up
    case item(basename: String, extension: String?)
        
    public init(_ string: String) {
        switch string {
            case ".": self = .this
            case "..": self = .up
            default:
                var ext: String? = (string as NSString).pathExtension
                if ext?.isEmpty == true { ext = nil }
                
                let name = (string as NSString).deletingPathExtension
                self = .item(basename: name, extension: ext)
        }
    }
    
    internal var pathString: String {
        switch self {
            case .this: return "."
            case .up: return ".."
            case .item(let s, let se):
                if let se = se {
                    return s + "." + se
                }
                return s
        }
    }
    
    public var itemString: String? {
        guard case .item = self else { return nil }
        return pathString
    }
    
    public var itemBaseName: String? {
        guard case .item(let basename, _) = self else {
            return nil
        }
        return basename
    }
    
    public var itemExtension: String? {
        guard case .item(_, let ext) = self else {
            return nil
        }
        return ext
    }
}

public protocol PathProtocol: Hashable, CustomDebugStringConvertible, Sendable {
    
    var components: Array<PathComponent> { get }
    var fileSystemPath: String { get }
    
    init(_ components: Array<PathComponent>)
    
}

extension PathProtocol {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.components == rhs.components
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components.count)
    }
    
    public var debugDescription: String {
        return fileSystemPath
    }
    
    public var lastComponent: PathComponent? { return components.last }
    public var lastItem: String? { return components.last?.itemString }
    
    public var `extension`: String? {
        guard case .some(.item(_, let e)) = components.last else { return nil }
        return e
    }
    
    public func modifyingLastItem(_ modifier: (String, String?) -> (String, String?)?) -> Self {
        var pieces = self.components
        guard case .some(.item(let s, let e)) = pieces.popLast() else { return self }
        if let (name, ext) = modifier(s, e) {
            pieces.append(.item(basename: name, extension: ext))
        }
        return Self.init(pieces)
    }
    
    public func deletingExtension() -> Self {
        return modifyingLastItem { (s, _) in return (s, nil) }
    }
    
    public func deletingLastComponent() -> Self {
        return modifyingLastItem { (_, _) in return nil }
    }
    
    public func trimming(_ path: RelativePath) -> Self {
        var pieces = self.components
        var toRemove = path.components
        
        while pieces.isEmpty == false && toRemove.isEmpty == false && pieces.last == toRemove.last {
            _ = pieces.popLast()
            _ = toRemove.popLast()
        }
        return Self.init(pieces)
    }
    
    public func deletingFirstComponent() -> Self {
        var pieces = self.components
        _ = pieces.removeFirst()
        return Self.init(pieces)
    }
    
    public func appending(components: String...) -> Self {
        let pieces = components.map { PathComponent($0) }
        return Self.init(self.components + pieces)
    }
    
    public func appending(component: String) -> Self {
        return Self.init(self.components + [PathComponent(component)])
    }
    
    public func appending(component: PathComponent) -> Self {
        return Self.init(self.components + [component])
    }
    
    public func appending(path: RelativePath) -> Self {
        return Self.init(self.components + path.components)
    }
    
    public func appending(extension ext: String) -> Self {
        return modifyingLastItem { (n, e) in
            guard let existing = e else { return (n, ext) }
            guard let last = (n as NSString).appendingPathExtension(existing) else { return (n, e) }
            return (last, ext)
        }
    }
    
    public func appending(lastItemPiece piece: String) -> Self {
        return modifyingLastItem { ($0+piece, $1) }
    }
    
    public func replacingLast(extension ext: String) -> Self {
        return modifyingLastItem { (s, _) in return (s, ext) }
    }
    
    public func containedWithin(name: String? = nil, extensions: Set<String>? = nil) -> Bool {
        if name == nil && `extension` == nil { return true }
        
        let nameMatcher: (String) -> Bool
        if let n = name {
            nameMatcher = { $0 == n }
        } else {
            nameMatcher = { _ in true }
        }
        
        let extMatcher: (String?) -> Bool
        if let e = extensions {
            extMatcher = { $0.map { e.contains($0) } ?? false }
        } else {
            extMatcher = { _ in true }
        }
        
        for component in components.dropLast() {
            switch component {
                case .item(let n, let e):
                    if nameMatcher(n) && extMatcher(e) { return true }
                
                default: continue
            }
        }
        return false
    }
    
}
