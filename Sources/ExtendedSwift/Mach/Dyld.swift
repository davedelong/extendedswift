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
    
    public struct Image: CustomStringConvertible {
        
        public struct ImageError: Error, CustomStringConvertible {
            
            public enum Kind {
                case cannotLoadImage
                case cannotLocateSymbol(String)
            }
            
            public let kind: Kind
            public let description: String
        }
        
        private static let dlopenHandleLock = NSLock()
        private static var dlopenHandles = Dictionary<String, UnsafeMutableRawPointer>()
        
        public let name: String
        public let header: Mach.Header
        
        public var description: String {
            return "\(header): \(name)"
        }
        
        public func symbol(named: String) throws -> UnsafeRawPointer {
            let handle: UnsafeMutableRawPointer = try Self.dlopenHandleLock.withLock {
                if let existing = Self.dlopenHandles[name] { return existing }
                
                if let h = dlopen(name, RTLD_LAZY | RTLD_NOLOAD) {
                    Self.dlopenHandles[name] = h
                    return h
                } else {
                    let err = String(cString: dlerror())
                    throw ImageError(kind: .cannotLoadImage, description: err)
                }
            }
            
            guard let symbol = dlsym(handle, named) else {
                throw ImageError(kind: .cannotLocateSymbol(named),
                                 description: "Cannot locate symbol '\(named)' in \(self)")
            }
            
            return UnsafeRawPointer(symbol)
        }
        
    }
    
}
