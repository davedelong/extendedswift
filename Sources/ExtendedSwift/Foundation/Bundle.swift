//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension Bundle {
    
    public var shortBundleVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public var bundleVersion: String {
        return shortBundleVersion ??
            object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ??
            ""
    }
    
    public var name: String {
        return (object(forInfoDictionaryKey: "CFBundleName") as? String) ??
        (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
        bundleIdentifier ??
        bundleURL.lastPathComponent
    }

}
