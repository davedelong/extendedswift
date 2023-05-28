//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/28/23.
//

import Foundation
import ExtendedSwift
@_implementationOnly import _ExtendedKit

public class AppSession {
    public static func initialize(_ scope: String) {
        if _current == nil {
            _current = AppSession(scope: scope)
        }
    }
    
    private static var _current: AppSession?
    
    public static var current: AppSession { _current !! "Missing call to AppSession.initialize(_:)" }
    
    public let uuid: UUID
    public let logFolder: URL
    
    public var allCrashFiles: Array<URL> { app_session_all_crash_files() }
    
    private init(scope: String) {
        uuid = scope.withCString { app_session_initialize($0) }
        logFolder = app_session_log_folder()
    }
    
    public func addCrashMetadata(key: String, value: Bool) { app_session_crash_metadata_add_bool(key, value) }
    public func addCrashMetadata(key: String, value: Int) { app_session_crash_metadata_add_int(key, value) }
    public func addCrashMetadata(key: String, value: Double) { app_session_crash_metadata_add_double(key, value) }
    public func addCrashMetadata(key: String, value: String) { app_session_crash_metadata_add_string(key, value) }
}
