//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/28/23.
//

import Foundation
import ExtendedSwift
@_implementationOnly import ExtendedObjC

public class AppSession {
    
    @discardableResult
    public static func initialize(groupIdentifier: String? = nil) -> AppSession {
        if _current == nil {
            var group = groupIdentifier
            if group == nil {
                let entitlements = ProcessInfo.processInfo.entitlementsDictionary
                let groups = entitlements["com.apple.security.application-groups"] as? Array<String> ?? []
                group = groups.first
            }
            _current = AppSession(group: group)
        }
        return AppSession.current
    }
    
    private static var _current: AppSession?
    
    public static var current: AppSession { _current !! "Missing call to AppSession.initialize(_:)" }
    
    public let uuid: UUID
    public let sandbox: Sandbox
    
    public var allCrashFiles: Array<URL> { app_session_all_crash_files() }
    
    private init(group: String?) {
        self.sandbox = Sandbox(groupIdentifier: group)
        let logs = sandbox.logs.fileURL
        uuid = app_session_initialize(logs)
    }
    
    public func addCrashMetadata(key: String, value: Bool) { app_session_crash_metadata_add_bool(key, value) }
    public func addCrashMetadata(key: String, value: Int) { app_session_crash_metadata_add_int(key, value) }
    public func addCrashMetadata(key: String, value: Double) { app_session_crash_metadata_add_double(key, value) }
    public func addCrashMetadata(key: String, value: String) { app_session_crash_metadata_add_string(key, value) }
}
