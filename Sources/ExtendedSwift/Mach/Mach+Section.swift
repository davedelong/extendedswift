//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation
import MachO

extension Mach {
    
    public struct Section {
        internal let header: Mach.Header
        internal let rawPointer: UnsafeRawPointer
        
        internal var sectionSize: Int {
            header.is64Bit ? MemoryLayout<section_64>.size : MemoryLayout<section>.size
        }
        
        internal var flags: UInt32 {
            if header.is64Bit {
                let pointer = rawPointer.assumingMemoryBound(to: section_64.self)
                return pointer.pointee.flags.swapping(header.needsSwapping)
            } else {
                let pointer = rawPointer.assumingMemoryBound(to: section.self)
                return pointer.pointee.flags.swapping(header.needsSwapping)
            }
        }
        
        public var segmentName: String {
            // 32 and 64-bit sections have the same segname size
            let pointer = rawPointer.load(as: section.self)
            return withUnsafePointer(to: pointer.segname) { tuplePtr in
                let start = tuplePtr.pointer(to: \.0)!
                return String(cString: start, maxLength: 16)!
            }
        }
        
        public var name: String {
            // 32 and 64-bit segments have the same sectname size
            let pointer = rawPointer.load(as: section.self)
            return withUnsafePointer(to: pointer.sectname) { tuplePtr in
                let start = tuplePtr.pointer(to: \.0)!
                return String(cString: start, maxLength: 16)!
            }
        }
        
        public var sectionType: SectionType {
            return SectionType(rawValue: UInt8(self.flags & UInt32(SECTION_TYPE)))
        }
        
        public var dataSize: UInt64 {
            if header.is64Bit {
                let pointer = rawPointer.assumingMemoryBound(to: section_64.self)
                return pointer.pointee.size.swapping(header.needsSwapping)
            } else {
                let pointer = rawPointer.assumingMemoryBound(to: section.self)
                return UInt64(pointer.pointee.size.swapping(header.needsSwapping))
            }
        }
        
        public var dataPointer: UnsafeRawPointer? {
            guard dataSize > 0 else { return nil }
            
            let offset: UInt32
            if header.is64Bit {
                let pointer = rawPointer.assumingMemoryBound(to: section_64.self)
                offset = pointer.pointee.offset.swapping(header.needsSwapping)
            } else {
                let pointer = rawPointer.assumingMemoryBound(to: section.self)
                offset = pointer.pointee.offset.swapping(header.needsSwapping)
            }
            
            return header.pointer.advanced(by: Int(offset))
        }
        
        public var dataBuffer: UnsafeBufferPointer<UInt8>? {
            let offset: UInt32
            let size: Int
            
            if header.is64Bit {
                let pointer = rawPointer.assumingMemoryBound(to: section_64.self)
                offset = pointer.pointee.offset.swapping(header.needsSwapping)
                size = Int(pointer.pointee.size.swapping(header.needsSwapping))
            } else {
                let pointer = rawPointer.assumingMemoryBound(to: section.self)
                offset = pointer.pointee.offset.swapping(header.needsSwapping)
                size = Int(pointer.pointee.size.swapping(header.needsSwapping))
            }
            
            guard size > 0 else { return nil }
            
            let start = header.pointer.advanced(by: Int(offset))
            return UnsafeBufferPointer(pointer: start, count: size)
        }
        
    }
    
    public struct SectionType: RawRepresentable {
        public static let regular = SectionType(rawValue: UInt8(S_REGULAR))
        public static let zeroFill = SectionType(rawValue: UInt8(S_ZEROFILL))
        public static let cStringLiterals = SectionType(rawValue: UInt8(S_CSTRING_LITERALS))
        public static let fourByteLiterals = SectionType(rawValue: UInt8(S_4BYTE_LITERALS))
        public static let eightByteLiterals = SectionType(rawValue: UInt8(S_8BYTE_LITERALS))
        public static let literalPointers = SectionType(rawValue: UInt8(S_LITERAL_POINTERS))
        public static let nonLazySymbolPointers = SectionType(rawValue: UInt8(S_NON_LAZY_SYMBOL_POINTERS))
        public static let lazySymbolPointers = SectionType(rawValue: UInt8(S_LAZY_SYMBOL_POINTERS))
        public static let symbolStubs = SectionType(rawValue: UInt8(S_SYMBOL_STUBS))
        public static let modInitFunctionPointers = SectionType(rawValue: UInt8(S_MOD_INIT_FUNC_POINTERS))
        public static let modTermFunctionPointers = SectionType(rawValue: UInt8(S_MOD_TERM_FUNC_POINTERS))
        public static let coalesced = SectionType(rawValue: UInt8(S_COALESCED))
        public static let gbZerofill = SectionType(rawValue: UInt8(S_GB_ZEROFILL))
        public static let interposing = SectionType(rawValue: UInt8(S_INTERPOSING))
        public static let sixteenByteLiterals = SectionType(rawValue: UInt8(S_16BYTE_LITERALS))
        public static let dtraceObjectFormat = SectionType(rawValue: UInt8(S_DTRACE_DOF))
        public static let lazyDylibSymbolPointers = SectionType(rawValue: UInt8(S_LAZY_DYLIB_SYMBOL_POINTERS))
        public static let threadLocalRegular = SectionType(rawValue: UInt8(S_THREAD_LOCAL_REGULAR))
        public static let threadLocalZerofill = SectionType(rawValue: UInt8(S_THREAD_LOCAL_ZEROFILL))
        public static let threadLocalVariables = SectionType(rawValue: UInt8(S_THREAD_LOCAL_VARIABLES))
        public static let threadLocalVariablePointers = SectionType(rawValue: UInt8(S_THREAD_LOCAL_VARIABLE_POINTERS))
        public static let threadLocalInitFunctionPointers = SectionType(rawValue: UInt8(S_THREAD_LOCAL_INIT_FUNCTION_POINTERS))
        public static let initFunctionOffsets = SectionType(rawValue: UInt8(S_INIT_FUNC_OFFSETS))
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    public struct Flags: OptionSet {
        public static let cStringLiterals = Flags(rawValue: UInt32(S_CSTRING_LITERALS))
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
    }
    
}
