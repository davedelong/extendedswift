//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

prefix operator /

public prefix func / (rhs: String) -> Path {
    return Path(RelativePath(path: rhs).components)
}

public prefix func / (rhs: RelativePath) -> Path {
    return Path(rhs.components)
}

public struct Path: PathProtocol {
    
    public static func / (lhs: Self, rhs: String) -> Path {
        let components = lhs.components + RelativePath(path: rhs).components
        return Path(components)
    }
    
    public static func / (lhs: Self, rhs: RelativePath) -> Path {
        let components = lhs.components + rhs.components
        return Path(components)
    }
    
    public static let root = Path([])
    public static let temporaryDirectory = Path(fileSystemPath: NSTemporaryDirectory())
    
    public let components: Array<PathComponent>
    
    public var fileSystemPath: String {
        return PathSeparator + components.map(\.pathString).joined(separator: PathSeparator)
    }
    
    public var fileURL: URL {
        return URL(fileURLWithPath: fileSystemPath)
    }
    
    public init(_ components: Array<PathComponent>) {
        self.components = PathComponent.reduce(components, allowRelative: false)
    }
    
    public init(_ url: URL) {
        let pathComponents = url.pathComponents.filter { $0 != PathSeparator }
        self.init(pathComponents.map { PathComponent($0) })
    }
    
    public init(fileSystemPath: StaticString) {
        self.init(fileSystemPath: fileSystemPath.description)
    }
    
    public init(fileSystemPath: String) {
        let expanded = (fileSystemPath as NSString).expandingTildeInPath
        let pieces = (expanded as NSString).pathComponents.filter { $0 != PathSeparator }
        self.init(pieces.map { PathComponent($0) })
    }
    
    public func resolvingSymlinks() -> Path {
        let resolvedURL = fileURL.resolvingSymlinksInPath()
        return Path(resolvedURL)
    }
    
    public subscript(extendedAttribute name: String) -> Data? {
        get {
            let path = fileSystemPath
            let length = getxattr(path, name, nil, 0, 0, 0)
            if length < 0 { return nil }
            
            var data = Data(repeating: 0, count: length)
            let written = data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                return getxattr(path, name, ptr.baseAddress, length, 0, 0)
            }
            
            return written > 0 ? data : nil
        }
        nonmutating set {
            if let data = newValue {
                let nsData = data as NSData
                setxattr(fileSystemPath, name, nsData.bytes, nsData.length, 0, 0)
            } else {
                removexattr(fileSystemPath, name, 0)
            }
        }
    }
    
    public var extendedAttributeNames: Array<String> {
        get throws {
            var final = Array<String>()
            var listSize = listxattr(fileSystemPath, nil, 0, 0)
            if listSize < 0 {
                throw NSError(domain: "extendedswift.xattr", code: Int(errno), userInfo: [
                    "path": fileSystemPath
                ])
            }
            
            if listSize == 0 { return [] }
            
            var data = Data(repeating: 0, count: listSize)
            listSize = data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                return listxattr(fileSystemPath, ptr.baseAddress, listSize, 0)
            }
            
            var startOfNextName = data.startIndex
            while startOfNextName < data.endIndex {
                guard let nextNull = data[startOfNextName...].firstIndex(of: 0) else {
                    break
                }
                
                let nameBytes = data[startOfNextName ..< nextNull]
                if let nameString = String(data: nameBytes, encoding: .utf8) {
                    final.append(nameString)
                }
                
                startOfNextName = data.index(after: nextNull)
            }
            
            return final
        }
    }
    
    public var extendedAttributes: Dictionary<String, Data> {
        get throws {
            var final = Dictionary<String, Data>()
            let names = try self.extendedAttributeNames
            
            for name in names {
                if let data = self[extendedAttribute: name] {
                    final[name] = data
                }
            }
            
            return final
        }
    }
    
    public func relativeTo(_ start: Path) -> RelativePath {
        var startComponents = start.components
        var destComponents = self.components
        
        while let s = startComponents.first, let d = destComponents.first, s == d {
            startComponents.removeFirst()
            destComponents.removeFirst()
        }
        
        let ups = Array(repeating: PathComponent.up, count: startComponents.count)
        var final = ups + destComponents
        
        if final.isEmpty { final = [.this] }
        
        return RelativePath(final, shouldReduce: false)
    }
    
    public func contains(_ other: Path) -> Bool {
        return fileURL.contains(other.fileURL)
    }
    
    
    public var isIncludedInBackup: Bool {
        get { fileURL.isIncludedInBackup }
        nonmutating set { fileURL.isIncludedInBackup = newValue }
    }
}

