//
//  File.swift
//  
//
//  Created by Dave DeLong on 2/1/24.
//

import Foundation

extension FileHandle {
    
    public convenience init(forReading path: Path) throws {
        try self.init(forReadingFrom: path.fileURL)
    }
    
    public convenience init(forWriting path: Path) throws {
        try self.init(forWritingTo: path.fileURL)
    }
    
    public convenience init(forUpdating path: Path) throws {
        try self.init(forUpdating: path.fileURL)
    }
    
}
