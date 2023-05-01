//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

extension FileManager {
    
    public func directoryExists(at url: URL) -> Bool {
        return self.folderExists(at: url)
    }
    
    public func createDirectory(at url: URL, withIntermediateDirectorys: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        
        try self.createDirectory(atPath: url.path(percentEncoded: false),
                                 withIntermediateDirectories: withIntermediateDirectorys,
                                 attributes: attributes)
    }
    
    public func folderExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir)
        return exists && isDir.boolValue == true
    }
    
    public func fileExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir)
        return exists && isDir.boolValue == false
    }
    
    public func displayName(at url: URL) -> String {
        return self.displayName(atPath: url.path(percentEncoded: false))
    }
}
