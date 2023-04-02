//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension URL {
    
    public var absolutePath: AbsolutePath { AbsolutePath(fileSystemPath: self.path(percentEncoded: false)) }
    
}

extension URLComponents {
    
    public var absolutePath: AbsolutePath {
        get { AbsolutePath(fileSystemPath: self.path) }
        set { self.path = newValue.fileSystemPath }
    }
    
}
