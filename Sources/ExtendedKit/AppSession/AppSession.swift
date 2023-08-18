//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/28/23.
//

import Foundation
import Logging
@_exported import ExtendedSwift
@_implementationOnly import PrivateAPI

public class AppSession {
    
    public enum GroupContainer {
        case none
        case `default`
        case explicit(String)
    }
    
    public typealias LogHandlers = (String, Sandbox) -> [LogHandler]
    
    @discardableResult
    public static func initialize(groupContainer: GroupContainer = .default, logHandlers: LogHandlers? = nil) -> AppSession {
        if _current == nil {
            _current = AppSession(group: groupContainer, logHandlers: logHandlers)
        }
        return AppSession.current
    }
    
    private static var _current: AppSession?
    
    public static var current: AppSession { _current !! "Missing call to AppSession.initialize(_:)" }
    
    public let uuid: UUID
    public let sandbox: Sandbox
    public let entitlements: Entitlements
    public let log: Logger
    
    public var allCrashFiles: Array<URL> { app_session_all_crash_files() }
    
    private init(group: GroupContainer, logHandlers: LogHandlers?) {
        // first, read the entitlements
        self.entitlements = ProcessInfo.processInfo.entitlements
        
        // with the entilements, we can discern the app's group, if there is one
        let actualGroup: String?
        switch group {
            case .none: actualGroup = nil
            case .default: actualGroup = entitlements.applicationGroups?.first
            case .explicit(let g): actualGroup = g
        }
        let sandbox = Sandbox(groupIdentifier: actualGroup)
        
        // with the sandbox, we can locate the logs folder
        self.sandbox = sandbox
        self.uuid = app_session_initialize(sandbox.logsPath.fileURL)
        
        // with the logs folder, we can bootstrap the logging system
        LoggingSystem.bootstrap({ name in
            let handlers = logHandlers?(name, sandbox) ?? []
            
            let handler: LogHandler
            switch handlers.count {
                case 0: handler = StreamLogHandler.standardOutput(label: name)
                case 1: handler = handlers[0]
                default: handler = MultiplexLogHandler(handlers)
            }
            
            var r = Redactor(inner: handler)
            r.logLevel = .trace
            return r
        })
        
        // finally with the logging system, we can initialize the rest of the app session
        self.log = Logger.named("AppSession")
        log.trace("Session \(self.uuid)")
        log.trace("Log folder: \(self.sandbox.logsPath.fileSystemPath)")
    }
    
    public func addCrashMetadata(key: String, value: Bool) { app_session_crash_metadata_add_bool(key, value) }
    public func addCrashMetadata(key: String, value: Int) { app_session_crash_metadata_add_int(key, value) }
    public func addCrashMetadata(key: String, value: Double) { app_session_crash_metadata_add_double(key, value) }
    public func addCrashMetadata(key: String, value: String) { app_session_crash_metadata_add_string(key, value) }
}
