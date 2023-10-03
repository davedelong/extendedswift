//
//  File.swift
//
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation

extension Mach {
    
    public struct Segment: MachLoadCommand, CustomStringConvertible {
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public init(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
        }
        
        public var name: String? {
            // 32 and 64-bit segments have the same segname size
            let p = pointer.rebound(to: segment_command.self)
            guard let namePtr = p.pointer(to: \.segname.0) else { return nil }
            return String(cString: namePtr, maxLength: 16)
        }
        
        public var description: String { "\(name ?? "Unknown Segment") @ \(pointer)" }
        
        public var sectionCount: Int {
            if is64Bit {
                let cmd = pointer.rebound(to: segment_command_64.self)
                return Int(cmd.pointee.nsects.swapping(header.needsSwapping))
            } else {
                let cmd = pointer.rebound(to: segment_command.self)
                return Int(cmd.pointee.nsects.swapping(header.needsSwapping))
            }
        }
        
        public var sections: some Sequence<Mach.Section> {
            let sectionStart: UnsafeRawPointer
            let sectionCount: UInt32
            if is64Bit {
                let cmd = pointer.rebound(to: segment_command_64.self)
                sectionCount = cmd.pointee.nsects.swapping(header.needsSwapping)
                sectionStart = rawPointer.advanced(by: MemoryLayout<segment_command_64>.size)
            } else {
                let cmd = pointer.rebound(to: segment_command.self)
                sectionCount = cmd.pointee.nsects.swapping(header.needsSwapping)
                sectionStart = rawPointer.advanced(by: MemoryLayout<segment_command>.size)
            }
            
            let state = (offset: 0, next: sectionStart)
            
            return sequence(state: state, next: { state in
                if state.offset >= sectionCount { return nil }
                
                let section = Section(header: self.header, rawPointer: state.next)
                state.next = state.next.advanced(by: Int(section.sectionSize))
                state.offset += 1
                return section
            })
        }
        
    }
    
}
