//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension FileManager {

    public static var applicationCacheDirectory: Path { return appCacheDirectory }
    public static var applicationSupportDirectory: Path { return appSupportDirectory }
    
    public func path(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, appropriateFor path: Path? = nil, create shouldCreate: Bool = true) throws -> Path {
        let result = try self.url(for: directory, in: domain, appropriateFor: path?.fileURL, create: shouldCreate)
        return Path(result)
    }
    
    public func containerPath(for groupIdentifier: String) -> Path? {
        guard let url = self.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            return nil
        }
        return Path(url)
    }
    
    public func pathExists(_ path: Path) -> Bool {
        var isDir = false
        return pathExists(path, isDirectory: &isDir)
    }
    
    public func pathExists(_ path: Path, isDirectory: inout Bool) -> Bool {
        var isFolder: ObjCBool = false
        if self.fileExists(atPath: path.fileSystemPath, isDirectory: &isFolder) {
            isDirectory = isFolder.boolValue
            return true
        }
        return false
    }
    
    public func directoryExists(at path: Path) -> Bool {
        return folderExists(at: path)
    }
    
    public func folderExists(at path: Path) -> Bool {
        var isFolder = false
        let exists = pathExists(path, isDirectory: &isFolder)
        return exists && isFolder
    }
    
    public func fileExists(at path: Path) -> Bool {
        var isFolder = false
        let exists = pathExists(path, isDirectory: &isFolder)
        return exists && isFolder == false
    }
    
    public func copyItem(at path: Path, to newPath: Path) throws {
        try copyItem(at: path.fileURL, to: newPath.fileURL)
    }
    
    @discardableResult
    public func createFile(atPath path: Path, contents: Data? = nil, attributes: Dictionary<FileAttributeKey, Any>? = nil) -> Bool {
        return createFile(atPath: path.fileSystemPath, contents: contents, attributes: attributes)
    }
    
    public func createDirectory(at path: Path, withIntermediateDirectories: Bool = true, attributes: Dictionary<FileAttributeKey, Any>? = nil) throws {
        try createDirectory(at: path.fileURL, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }
    
    public func relativeContentsOfDirectory(at path: RelativePath, relativeTo base: Path) -> Array<RelativePath> {
        let absolute = base.appending(path: path)
        guard let children = try? self.contentsOfDirectory(atPath: absolute.fileSystemPath) else { return [] }
        return children.map { path.appending(component: $0) }
    }
    
    public func relativeContentsOfDirectory(at path: Path) -> Array<RelativePath> {
        guard let children = try? self.contentsOfDirectory(atPath: path.fileSystemPath) else { return [] }
        return children.map { RelativePath($0) }
    }
    
    public func contentsOfDirectory(at path: Path, includingPropertiesForKeys keys: Array<URLResourceKey>? = nil, options mask: FileManager.DirectoryEnumerationOptions = []) -> Array<Path> {
        let contents = (try? contentsOfDirectory(at: path.fileURL, includingPropertiesForKeys: keys, options: mask)) ?? []
        return contents.map { Path($0) }
    }
    
    public func contentsOfFile(at path: Path) throws -> Data {
        guard self.fileExists(at: path) else {
            throw CocoaError(.fileNoSuchFile)
        }
        return self.contents(atPath: path.fileSystemPath) ?? Data()
    }
    
    public func removeItem(at path: Path) throws {
        try removeItem(atPath: path.fileSystemPath)
    }
    
    public func moveItem(at srcPath: Path, to dstPath: Path) throws {
        try moveItem(atPath: srcPath.fileSystemPath, toPath: dstPath.fileSystemPath)
    }
    
    public func symlinkItem(at srcPath: Path, to dstPath: Path) throws {
        let src = srcPath.fileSystemPath
        let dst = dstPath.fileSystemPath
        
        try src.withCString { srcStr in
            try dst.withCString { dstStr in
                let status = symlink(srcStr, dstStr)
                if status != 0 {
                    let error = errno
                    throw NSError(domain: "extendedswift.symlink", code: Int(error), userInfo: [
                        "source": src,
                        "destination": dst
                    ])
                }
            }
        }
    }
    
    public func hardlinkItem(at srcPath: Path, to dstPath: Path) throws {
        let src = srcPath.fileSystemPath
        let dst = dstPath.fileSystemPath
        
        try src.withCString { srcStr in
            try dst.withCString { dstStr in
                let status = link(srcStr, dstStr)
                if status != 0 {
                    let error = errno
                    throw NSError(domain: "extendedswift.hardlink", code: Int(error), userInfo: [
                        "source": src,
                        "destination": dst
                    ])
                }
            }
        }
    }
    
    public func displayName(at path: Path) -> String {
        return displayName(atPath: path.fileSystemPath)
    }
    
    @discardableResult
    public func trashItem(at path: Path) throws -> Path? {
        var resultingURL: NSURL?
        try self.trashItem(at: path.fileURL, resultingItemURL: &resultingURL)
        return resultingURL.map { Path($0 as URL) }
    }
}

private func appSpecificDirectory(directory: FileManager.SearchPathDirectory) -> Path {
    let fm = FileManager.default
    let folder = try! fm.path(for: directory)
    let id = Bundle.main.name
    let appFolder = folder.appending(component: id)
    if fm.folderExists(at: appFolder) == false {
        try? fm.createDirectory(at: appFolder)
    }
    return appFolder
}

private let appCacheDirectory: Path = { return appSpecificDirectory(directory: .cachesDirectory) }()
private let appSupportDirectory: Path = { return appSpecificDirectory(directory: .applicationSupportDirectory) }()

