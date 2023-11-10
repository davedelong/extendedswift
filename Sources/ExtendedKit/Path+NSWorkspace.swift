//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

#if os(macOS)

import AppKit

extension NSWorkspace {
    
    public func icon(for path: Path) -> NSImage {
        return self.icon(forFile: path.fileSystemPath)
    }
    
}

#endif
