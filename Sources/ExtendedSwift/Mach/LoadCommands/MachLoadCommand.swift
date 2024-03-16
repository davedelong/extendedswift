//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/1/23.
//

import Foundation
import MachO

public protocol MachLoadCommand: CustomStringConvertible {
    
    var header: Mach.Header { get }
    var pointer: UnsafePointer<load_command> { get }
    
    init?(header: Mach.Header, pointer: UnsafePointer<load_command>)
}

extension MachLoadCommand {
    
    public var commandType: Mach.LoadCommandType {
        let rawValue = pointer.pointee.cmd.swapping(header.needsSwapping)
        return Mach.LoadCommandType(rawValue: rawValue)
    }
    
    public var description: String { "\(commandType.name) @ \(pointer)" }
    
    public var is64Bit: Bool { header.is64Bit }
    
    public var rawPointer: UnsafeRawPointer { .init(pointer) }
    
    public var commandSize: UInt32 {
        return pointer.pointee.cmdsize.swapping(header.needsSwapping)
    }
    
    public init?(_ other: any MachLoadCommand) {
        self.init(header: other.header, pointer: other.pointer)
    }
    
    internal init?(header: Mach.Header, rawPointer: UnsafeRawPointer) {
        self.init(header: header, pointer: rawPointer.assumingMemoryBound(to: load_command.self))
    }
    
    internal func readLCString<T>(_ keyPath: KeyPath<T, lc_str>) -> String {
        let ptr = self.rawPointer.assumingMemoryBound(to: T.self)
        let offset = ptr.pointee[keyPath: keyPath].offset
        let size = self.commandSize
        let length = size - offset
        
        let string = rawPointer.withMemoryRebound(to: CChar.self, capacity: Int(size)) { ptr in
            let advanced = ptr.advanced(by: Int(offset))
            let str = String(cString: advanced, maxLength: Int(length))
            return str
        }
        
        return string ?? ""
    }
    
}

extension Mach {
    
    public struct LoadCommandType: RawRepresentable {
        public static let segment = LoadCommandType(rawValue: UInt32(LC_SEGMENT))
        public static let segment64 = LoadCommandType(rawValue: UInt32(LC_SEGMENT_64))
        public static let uuid = LoadCommandType(rawValue: UInt32(LC_UUID))
        public static let codeSignature = LoadCommandType(rawValue: UInt32(LC_CODE_SIGNATURE))
        public static let loadDylib = LoadCommandType(rawValue: UInt32(LC_LOAD_DYLIB))
        public static let loadWeakDylib = LoadCommandType(rawValue: LC_LOAD_WEAK_DYLIB)
        public static let rpath = LoadCommandType(rawValue: LC_RPATH)
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public var name: String {
            return commandNames[rawValue] ?? "Unknown Command: \(hex: rawValue)"
        }
    }
    
}

private let commandNames: Dictionary<UInt32, String> = [
    LC_REQ_DYLD: "LC_REQ_DYLD",
    UInt32(bitPattern: LC_SEGMENT): "LC_SEGMENT",
    UInt32(bitPattern: LC_SYMTAB): "LC_SYMTAB",
    UInt32(bitPattern: LC_SYMSEG): "LC_SYMSEG",
    UInt32(bitPattern: LC_THREAD): "LC_THREAD",
    UInt32(bitPattern: LC_UNIXTHREAD): "LC_UNIXTHREAD",
    UInt32(bitPattern: LC_LOADFVMLIB): "LC_LOADFVMLIB",
    UInt32(bitPattern: LC_IDFVMLIB): "LC_IDFVMLIB",
    UInt32(bitPattern: LC_IDENT): "LC_IDENT",
    UInt32(bitPattern: LC_FVMFILE): "LC_FVMFILE",
    UInt32(bitPattern: LC_PREPAGE): "LC_PREPAGE",
    UInt32(bitPattern: LC_DYSYMTAB): "LC_DYSYMTAB",
    UInt32(bitPattern: LC_LOAD_DYLIB): "LC_LOAD_DYLIB",
    UInt32(bitPattern: LC_ID_DYLIB): "LC_ID_DYLIB",
    UInt32(bitPattern: LC_LOAD_DYLINKER): "LC_LOAD_DYLINKER",
    UInt32(bitPattern: LC_ID_DYLINKER): "LC_ID_DYLINKER",
    UInt32(bitPattern: LC_PREBOUND_DYLIB): "LC_PREBOUND_DYLIB",
    UInt32(bitPattern: LC_ROUTINES): "LC_ROUTINES",
    UInt32(bitPattern: LC_SUB_FRAMEWORK): "LC_SUB_FRAMEWORK",
    UInt32(bitPattern: LC_SUB_UMBRELLA): "LC_SUB_UMBRELLA",
    UInt32(bitPattern: LC_SUB_CLIENT): "LC_SUB_CLIENT",
    UInt32(bitPattern: LC_SUB_LIBRARY): "LC_SUB_LIBRARY",
    UInt32(bitPattern: LC_TWOLEVEL_HINTS): "LC_TWOLEVEL_HINTS",
    UInt32(bitPattern: LC_PREBIND_CKSUM): "LC_PREBIND_CKSUM",
    LC_LOAD_WEAK_DYLIB: "LC_LOAD_WEAK_DYLIB",
    UInt32(bitPattern: LC_SEGMENT_64): "LC_SEGMENT_64",
    UInt32(bitPattern: LC_ROUTINES_64): "LC_ROUTINES_64",
    UInt32(bitPattern: LC_UUID): "LC_UUID",
    LC_RPATH: "LC_RPATH",
    UInt32(bitPattern: LC_CODE_SIGNATURE): "LC_CODE_SIGNATURE",
    UInt32(bitPattern: LC_SEGMENT_SPLIT_INFO): "LC_SEGMENT_SPLIT_INFO",
    LC_REEXPORT_DYLIB: "LC_REEXPORT_DYLIB",
    UInt32(bitPattern: LC_LAZY_LOAD_DYLIB): "LC_LAZY_LOAD_DYLIB",
    UInt32(bitPattern: LC_ENCRYPTION_INFO): "LC_ENCRYPTION_INFO",
    UInt32(bitPattern: LC_DYLD_INFO): "LC_DYLD_INFO",
    LC_DYLD_INFO_ONLY: "LC_DYLD_INFO_ONLY",
    LC_LOAD_UPWARD_DYLIB: "LC_LOAD_UPWARD_DYLIB",
    UInt32(bitPattern: LC_VERSION_MIN_MACOSX): "LC_VERSION_MIN_MACOSX",
    UInt32(bitPattern: LC_VERSION_MIN_IPHONEOS): "LC_VERSION_MIN_IPHONEOS",
    UInt32(bitPattern: LC_FUNCTION_STARTS): "LC_FUNCTION_STARTS",
    UInt32(bitPattern: LC_DYLD_ENVIRONMENT): "LC_DYLD_ENVIRONMENT",
    LC_MAIN: "LC_MAIN",
    UInt32(bitPattern: LC_DATA_IN_CODE): "LC_DATA_IN_CODE",
    UInt32(bitPattern: LC_SOURCE_VERSION): "LC_SOURCE_VERSION",
    UInt32(bitPattern: LC_DYLIB_CODE_SIGN_DRS): "LC_DYLIB_CODE_SIGN_DRS",
    UInt32(bitPattern: LC_ENCRYPTION_INFO_64): "LC_ENCRYPTION_INFO_64",
    UInt32(bitPattern: LC_LINKER_OPTION): "LC_LINKER_OPTION",
    UInt32(bitPattern: LC_LINKER_OPTIMIZATION_HINT): "LC_LINKER_OPTIMIZATION_HINT",
    UInt32(bitPattern: LC_VERSION_MIN_TVOS): "LC_VERSION_MIN_TVOS",
    UInt32(bitPattern: LC_VERSION_MIN_WATCHOS): "LC_VERSION_MIN_WATCHOS",
    UInt32(bitPattern: LC_NOTE): "LC_NOTE",
    UInt32(bitPattern: LC_BUILD_VERSION): "LC_BUILD_VERSION",
    LC_DYLD_EXPORTS_TRIE: "LC_DYLD_EXPORTS_TRIE",
    LC_DYLD_CHAINED_FIXUPS: "LC_DYLD_CHAINED_FIXUPS",
    LC_FILESET_ENTRY: "LC_FILESET_ENTRY",
    UInt32(bitPattern: LC_ATOM_INFO): "LC_ATOM_INFO",
]

