//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/22/23.
//

import Foundation
import Logging
import OSLog

public struct OSLogHandler: LogHandler {
    
    private let logger: os.Logger
    
    public var metadata: Logging.Logger.Metadata
    
    public var logLevel: Logging.Logger.Level
    
    public init(subsystem: String, label: String) {
        self.logger = os.Logger(subsystem: subsystem, category: label)
        self.metadata = [:]
        self.logLevel = .trace
    }
    
    public subscript(metadataKey _: String) -> Logging.Logger.Metadata.Value? {
        get { return nil }
        set(newValue) { }
    }
    
    public func log(level: Logging.Logger.Level, message: Logging.Logger.Message, metadata: Logging.Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let type: OSLogType
        switch level {
            case .trace: type = .debug
            case .debug: type = .debug
            case .info: type = .info
            case .notice: type = .default
            case .warning: type = .error
            case .error: type = .error
            case .critical: type = .fault
        }
        logger.log(level: type, "\(message.description, privacy: .auto)")
    }
    
}
