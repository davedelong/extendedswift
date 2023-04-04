//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

public struct AbsolutePath: Path {
    
    public static let root = AbsolutePath([])
    public static let temporaryDirectory = AbsolutePath(fileSystemPath: NSTemporaryDirectory())
    
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
    
    public func resolvingSymlinks() -> AbsolutePath {
        let resolvedURL = fileURL.resolvingSymlinksInPath()
        return AbsolutePath(resolvedURL)
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
    
    public func relativeTo(_ start: AbsolutePath) -> RelativePath {
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
    
    public func contains(_ other: AbsolutePath) -> Bool {
        return fileURL.contains(other.fileURL)
    }
}

