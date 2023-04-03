//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension Bundle {
    
    public var shortVersionString: String? {
        if let s = string(forInfoDictionaryKey: "CFBundleShortVersionString") { return s }
        return nil
    }
    
    public var versionString: String? {
        if let s = string(forInfoDictionaryKey: "CFBundleVersion") { return s }
        if let s = shortVersionString { return s }
        return ""
    }
    
    public var name: String {
        if let s = string(forInfoDictionaryKey: "CFBundleName") { return s }
        if let s = string(forInfoDictionaryKey: "CFBundleDisplayName") { return s }
        if let s = bundleIdentifier { return s }
        return bundleURL.lastPathComponent
    }
    
    public func string(forInfoDictionaryKey key: String) -> String? {
        return object(forInfoDictionaryKey: key) as? String
    }

}
