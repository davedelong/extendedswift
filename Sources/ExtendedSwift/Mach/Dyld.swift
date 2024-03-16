//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation
import MachO

public struct Dyld {
    
    public static var executable: Dyld.Image {
        return images.first(where: { $0.header.fileType == .executable })!
    }
    
    public static var images: some Sequence<Dyld.Image> {
        let count = _dyld_image_count()
        return sequence(state: 0 as UInt32, next: { state -> Dyld.Image? in
            
            while state < count {
                defer { state += 1 }
                guard let rawName = _dyld_get_image_name(state) else { continue }
                guard let rawHeader = _dyld_get_image_header(state) else { continue }
                
                let slide = _dyld_get_image_vmaddr_slide(state)
                guard let header = Mach.Header(rawValue: rawHeader, slide: slide) else { continue }
                
                return Dyld.Image(name: String(cString: rawName),
                                  header: header)
            }
            
            return nil
        })
    }
    
    public static func `open`(_ path: Path, flags: OpenFlags) throws -> Image {
        return try Image(load: path, flags: flags)
    }
    
    public struct Image: CustomStringConvertible {
        
        private static let dlopenHandleLock = NSLock()
        private static var dlopenHandles = Dictionary<String, UnsafeMutableRawPointer>()
        
        public let name: String
        public let header: Mach.Header
        
        public var description: String {
            return "\(header): \(name)"
        }
        
        internal init(name: String, header: Mach.Header) {
            self.name = name
            self.header = header
        }
        
        internal init(load: Path, flags: OpenFlags) throws {
            self.name = load.fileSystemPath
            self.header = try Self.dlopenHandleLock.withLock {
                let path = load.fileSystemPath
                
                let handle: UnsafeMutableRawPointer
                if let existing = Self.dlopenHandles[path] {
                    handle = existing
                } else if let h = dlopen(path, flags.mode) {
                    handle = h
                } else {
                    throw ImageError(kind: .cannotLoadImage, 
                                     description: String(cString: dlerror()))
                }
                
                var info = Dl_info()
                let status = dladdr(handle, &info)
                if status == 0 {
                    throw ImageError(kind: .cannotLoadImage, description: "Cannot locate header for dlhandle")
                }
                
                let machPointer = info.dli_fbase.assumingMemoryBound(to: mach_header.self)
                guard let header = Mach.Header(rawValue: machPointer) else {
                    throw ImageError(kind: .cannotLoadImage, description: "Invalid dli_fbase")
                }
                return header
            }
        }
        
        public func symbol(named: String) throws -> UnsafeRawPointer {
            let handle: UnsafeMutableRawPointer = try Self.dlopenHandleLock.withLock {
                if let existing = Self.dlopenHandles[name] { return existing }
                
                if let h = dlopen(name, RTLD_LAZY | RTLD_NOLOAD) {
                    Self.dlopenHandles[name] = h
                    return h
                } else {
                    throw ImageError(kind: .cannotLoadImage, 
                                     description: String(cString: dlerror()))
                }
            }
            
            guard let symbol = dlsym(handle, named) else {
                throw ImageError(kind: .cannotLocateSymbol(named),
                                 description: "Cannot locate symbol '\(named)' in \(self)")
            }
            
            return UnsafeRawPointer(symbol)
        }
        
    }
    
    public struct OpenFlags {
        public var lazy: Bool
        public var global: Bool
        public var withoutLoading: Bool
        
        public init(lazy: Bool = false, global: Bool = true, withoutLoading: Bool = false) {
            self.lazy = lazy
            self.global = global
            self.withoutLoading = withoutLoading
        }
        
        internal var mode: Int32 {
            var mode: Int32 = 0
            mode |= lazy ? RTLD_LAZY : RTLD_NOW
            mode |= global ? RTLD_GLOBAL : RTLD_LOCAL
            if withoutLoading { mode |= RTLD_NOLOAD }
            return mode
        }
    }
    
    public struct ImageError: Error, CustomStringConvertible {
        
        public enum Kind {
            case cannotLoadImage
            case cannotLocateSymbol(String)
        }
        
        public let kind: Kind
        public let description: String
    }
    
}
