//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension FileManager {

    public static var applicationCacheDirectory: AbsolutePath { return appCacheDirectory }
    public static var applicationSupportDirectory: AbsolutePath { return appSupportDirectory }
    
    public func path(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, appropriateFor path: AbsolutePath? = nil, create shouldCreate: Bool = true) throws -> AbsolutePath {
        let result = try self.url(for: directory, in: domain, appropriateFor: path?.fileURL, create: shouldCreate)
        return AbsolutePath(result)
    }
    
    public func pathExists(_ path: AbsolutePath) -> Bool {
        var isDir = false
        return pathExists(path, isDirectory: &isDir)
    }
    
    public func pathExists(_ path: AbsolutePath, isDirectory: inout Bool) -> Bool {
        var isFolder: ObjCBool = false
        if self.fileExists(atPath: path.fileSystemPath, isDirectory: &isFolder) {
            isDirectory = isFolder.boolValue
            return true
        }
        return false
    }
    
    public func directoryExists(at path: AbsolutePath) -> Bool {
        return folderExists(at: path)
    }
    
    public func folderExists(at path: AbsolutePath) -> Bool {
        var isFolder = false
        let exists = pathExists(path, isDirectory: &isFolder)
        return exists && isFolder
    }
    
    public func fileExists(at path: AbsolutePath) -> Bool {
        var isFolder = false
        let exists = pathExists(path, isDirectory: &isFolder)
        return exists && isFolder == false
    }
    
    public func copyItem(at path: AbsolutePath, to newPath: AbsolutePath) throws {
        try copyItem(at: path.fileURL, to: newPath.fileURL)
    }
    
    @discardableResult
    public func createFile(atPath path: AbsolutePath, contents: Data? = nil, attributes: Dictionary<FileAttributeKey, Any>? = nil) -> Bool {
        return createFile(atPath: path.fileSystemPath, contents: contents, attributes: attributes)
    }
    
    public func createDirectory(at path: AbsolutePath, withIntermediateDirectories: Bool = true, attributes: Dictionary<FileAttributeKey, Any>? = nil) throws {
        try createDirectory(at: path.fileURL, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }
    
    public func relativeContentsOfDirectory(at path: RelativePath, relativeTo base: AbsolutePath) -> Array<RelativePath> {
        let absolute = base.appending(path: path)
        guard let children = try? self.contentsOfDirectory(atPath: absolute.fileSystemPath) else { return [] }
        return children.map { path.appending(component: $0) }
    }
    
    public func relativeContentsOfDirectory(at path: AbsolutePath) -> Array<RelativePath> {
        guard let children = try? self.contentsOfDirectory(atPath: path.fileSystemPath) else { return [] }
        return children.map { RelativePath($0) }
    }
    
    public func contentsOfDirectory(at path: AbsolutePath, includingPropertiesForKeys keys: [URLResourceKey]? = nil, options mask: FileManager.DirectoryEnumerationOptions = []) -> Array<AbsolutePath> {
        let contents = (try? contentsOfDirectory(at: path.fileURL, includingPropertiesForKeys: keys, options: mask)) ?? []
        return contents.map { AbsolutePath($0) }
    }
    
    public func removeItem(at path: AbsolutePath) throws {
        try removeItem(atPath: path.fileSystemPath)
    }
    
    public func moveItem(at srcPath: AbsolutePath, to dstPath: AbsolutePath) throws {
        try moveItem(atPath: srcPath.fileSystemPath, toPath: dstPath.fileSystemPath)
    }
    
    public func symlinkItem(at srcPath: AbsolutePath, to dstPath: AbsolutePath) throws {
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
    
    public func hardlinkItem(at srcPath: AbsolutePath, to dstPath: AbsolutePath) throws {
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
    
    public func displayName(at path: AbsolutePath) -> String {
        return displayName(atPath: path.fileSystemPath)
    }
    
    @discardableResult
    public func trashItem(at path: AbsolutePath) throws -> AbsolutePath? {
        var resultingURL: NSURL?
        try self.trashItem(at: path.fileURL, resultingItemURL: &resultingURL)
        return resultingURL.map { AbsolutePath($0 as URL) }
    }
}

private func appSpecificDirectory(directory: FileManager.SearchPathDirectory) -> AbsolutePath {
    let fm = FileManager.default
    let folder = try! fm.path(for: directory)
    let id = Bundle.main.name
    let appFolder = folder.appending(component: id)
    if fm.folderExists(at: appFolder) == false {
        try? fm.createDirectory(at: appFolder)
    }
    return appFolder
}

private let appCacheDirectory: AbsolutePath = { return appSpecificDirectory(directory: .cachesDirectory) }()
private let appSupportDirectory: AbsolutePath = { return appSpecificDirectory(directory: .applicationSupportDirectory) }()

