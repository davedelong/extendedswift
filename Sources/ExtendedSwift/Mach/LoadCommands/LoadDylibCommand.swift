//
//  File.swift
//  
//
//  Created by Dave DeLong on 3/15/24.
//

import Foundation
import MachO

extension Mach {
    
    public struct LoadDylib: MachLoadCommand {
        
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public var isWeak: Bool {
            self.commandType == .loadWeakDylib
        }
        
        public var name: String {
            return readLCString(\dylib_command.dylib.name)
        }
        
        public init?(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
            
            guard self.commandType == .loadDylib || self.commandType == .loadWeakDylib else { return nil }
        }
        
    }
    
}
