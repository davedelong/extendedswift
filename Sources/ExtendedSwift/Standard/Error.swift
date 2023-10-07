//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/18/23.
//

import Foundation

public struct AnyError: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    public let description: String
    public let underlyingError: Error?
    
    public init(_ description: String, function: StaticString = #function, fileID: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = fileID
        self.line = line
        self.description = description
        self.underlyingError = nil
    }
    
    public init(_ other: Error, function: StaticString = #function, fileID: StaticString = #fileID, line: UInt = #line) {
        if let any = other as? AnyError {
            self = any
        } else {
            self.function = function
            self.fileID = fileID
            self.line = line
            self.description = other.localizedDescription
            self.underlyingError = other
        }
    }
    
}

public struct UnimplementedError: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    
    public init(function: StaticString = #function, file: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = file
        self.line = line
    }
    
    public var description: String {
        "The function \(function) in \(fileID):\(line) is unimplemented. This is a developer error."
    }
    
}

public struct Unreachable: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    
    public init(function: StaticString = #function, file: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = file
        self.line = line
    }
    
    public var description: String {
        "The function \(function) in \(fileID):\(line) should be unreachable. This is a developer error."
    }
    
}
