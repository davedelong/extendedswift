//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/1/23.
//

import Foundation

extension Mach {
    
    public struct UUID: MachLoadCommand {
        
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public var uuid: Foundation.UUID {
            let ptr = pointer.rebound(to: uuid_command.self).pointer(to: \.uuid)!
            return Foundation.UUID(uuid: ptr.pointee)
        }
        
        public init?(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
            
            guard self.commandType == .uuid else { return nil }
        }
        
    }
    
}
