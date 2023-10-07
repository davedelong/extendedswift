//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation
import MachO

public enum Mach {
    
    public struct FileType: RawRepresentable {
        
        public static let executable = FileType(rawValue: MH_EXECUTE)
        
        public let rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
    
    public struct Header: CustomStringConvertible {
        
        internal var magic: UInt32 { rawValue.pointee.magic }
        internal var is32Bit: Bool { magic == MH_MAGIC || magic == MH_CIGAM }
        internal var is64Bit: Bool { magic == MH_MAGIC_64 || magic == MH_CIGAM_64 }
        internal var needsSwapping: Bool { magic == MH_CIGAM || magic == MH_CIGAM_64 }
        internal var isValid: Bool { is32Bit || is64Bit }
        
        internal let rawValue: UnsafePointer<mach_header>
        internal let slide: Int
        
        internal var pointer: UnsafeRawPointer { .init(rawValue) }
        internal var size: Int { is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size }
        
        public var fileType: FileType {
            let raw = rawValue.pointee.filetype.swapping(self.needsSwapping)
            return FileType(rawValue: Int32(bitPattern: raw))
        }
        
        public var cpuType: Int32 {
            rawValue.pointee.cputype.swapping(self.needsSwapping)
        }
        
        public var cpuSubType: Int32 {
            rawValue.pointee.cpusubtype.swapping(self.needsSwapping)
        }
        
        public var description: String {
            return "Header @ \(pointer)"
        }
        
        public var loadCommands: some Sequence<LoadCommand> {
            let numberOfSegments = rawValue.pointee.ncmds.swapping(self.needsSwapping)
            
            let firstSegment = pointer.advanced(by: size)
            let state = (offset: 0 as UInt32, next: firstSegment)
            return sequence(state: state, next: { state -> Mach.LoadCommand? in
                if state.offset >= numberOfSegments { return nil }
                
                let command = LoadCommand(header: self, rawPointer: state.next)!
                
                state.next = state.next.advanced(by: Int(command.commandSize))
                state.offset += 1
                
                return command
            })
            
        }
        
        init?(rawValue: UnsafePointer<mach_header>, slide: Int) {
            self.rawValue = rawValue
            self.slide = slide
            guard self.isValid else { return nil }
        }
        
        public init?(rawValue: UnsafePointer<mach_header>) {
            self.init(rawValue: rawValue, slide: 0)
        }
        
    }
    
}
