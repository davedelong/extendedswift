//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/18/23.
//

import Foundation

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
