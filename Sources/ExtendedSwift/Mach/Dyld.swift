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
        
        public let name: String
        public let header: Mach.Header
        
        public var description: String {
            return "\(header): \(name)"
        }
        
    }
    
}
