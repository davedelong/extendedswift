//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import Logging

struct Redactor: LogHandler {
    
    private(set) var inner: LogHandler
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { inner[metadataKey: key] }
        set { inner[metadataKey: key] = newValue }
    }
    
    var metadata: Logger.Metadata {
        get { inner.metadata }
        set { inner.metadata = newValue }
    }
    
    var logLevel: Logger.Level {
        get { inner.logLevel }
        set { inner.logLevel = newValue }
    }
    
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let redacted = Logger.Message(stringLiteral: message.description.redact())
        inner.log(level: level, message: redacted, metadata: metadata, source: source, file: file, function: function, line: line)
    }
    
    
}

extension String {
    
    fileprivate func redact() -> String {
        var copy = self
        copy.replaceAllMatches(of: redactor, with: #""\#(\.1)": "(redacted)""#)
        return copy
    }
    
}

private let redactor = /"(token|password|data)"\s*:\s*"(.+?)"/
