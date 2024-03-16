//
//  File.swift
//  
//
//  Created by Dave DeLong on 3/15/24.
//

import Foundation
import MachO

extension Mach {
    
    public struct RPath: MachLoadCommand {
        
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public var name: String {
            return readLCString(\rpath_command.path)
        }
        
        public init?(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
            
            guard self.commandType == .rpath else { return nil }
        }
    }
    
}
