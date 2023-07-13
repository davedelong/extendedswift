//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/5/23.
//

import Foundation

extension Data {
    
    public init(contentsOf path: Path, options: Data.ReadingOptions = []) throws {
        try self.init(contentsOf: path.fileURL, options: options)
    }
    
    public func write(to path: Path, options: Data.WritingOptions = []) throws {
        try self.write(to: path.fileURL, options: options)
    }
    
}

extension String {
    
    public init(contentsOf path: Path) throws {
        try self.init(contentsOf: path.fileURL)
    }
    
    public func write(to path: Path, atomically: Bool = true, encoding: String.Encoding = .utf8) throws {
        try self.write(to: path.fileURL, atomically: atomically, encoding: encoding)
    }
    
}
