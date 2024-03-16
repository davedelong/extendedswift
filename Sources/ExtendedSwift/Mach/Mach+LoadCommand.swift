//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation
import MachO

extension Mach {
    
    public struct LoadCommand: CustomStringConvertible, MachLoadCommand {
        
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public init(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
        }
        
    }
}
