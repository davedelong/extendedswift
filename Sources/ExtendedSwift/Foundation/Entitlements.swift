//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation

public struct Entitlements {
    
    let source: Dictionary<String, Any>
    
    public subscript(key: String) -> Any? {
        return source[key]
    }
    
    public subscript(string key: String) -> String? {
        return source[key] as? String
    }
    
}

extension Entitlements {
    
    public var teamIdentifier: String? { self[string: "com.apple.developer.team-identifier"] }
    public var appIdentifier: String? { self[string: "application-identifier"] }
    
    public var keychainAccessGroups: Array<String>? {
        self["keychain-access-groups"] as? Array<String>
    }
    
    public var applicationGroups: Array<String>? {
        self["com.apple.security.application-groups"] as? Array<String>
    }
    
    public var isSandboxed: Bool {
        #if os(macOS)
        (self["com.apple.security.app-sandbox"] as? Bool) == true
        #else
        return true
        #endif
    }
}
