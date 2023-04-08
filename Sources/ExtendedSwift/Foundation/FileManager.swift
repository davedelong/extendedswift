//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

extension FileManager {
    
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
