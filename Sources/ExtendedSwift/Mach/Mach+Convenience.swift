//
//  File.swift
//
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation

extension Mach.Header {
    
    public var allSections: some Sequence<Mach.Section> {
        return self.loadCommands
            .compactMap { Mach.Segment($0) }
            .flatMap { $0.sections }
    }
    
    public var codeSignature: Mach.CodeSignature? {
        return self.loadCommands.firstMap { Mach.CodeSignature($0) }
    }
    
    public var entitlements: Dictionary<String, Any>? {
        if let entitlements = codeSignature?.entitlements { return entitlements }
        // try reading it from __TEXT
        
        guard let section = allSections.first(where: { $0.segmentName == "__TEXT" && $0.name == "__entitlements" }) else {
            return nil
        }
        
        guard let dataBuffer = section.dataBuffer else { return nil }
        let data = Data(buffer: dataBuffer)
        
        let obj = try? PropertyListSerialization.propertyList(from: data, format: nil)
        return obj as? Dictionary<String, Any>
    }
    
    public var strings: some Sequence<String> {
        return allSections
            .filter { $0.sectionType == .cStringLiterals && $0.dataPointer != nil }
            .flatMap { section in
                let size = section.dataSize
                let pointer = section.dataPointer!
                let end = pointer.advanced(by: Int(size))
                
                let charPointer = pointer.assumingMemoryBound(to: CChar.self)
                
                return sequence(state: charPointer, next: { ptr -> String? in
                    while ptr.pointee == 0 && ptr < end {
                        ptr = ptr.successor()
                    }
                    if ptr >= end { return nil }
                    
                    let startOfString = ptr
                    var endOfString = ptr.successor()
                    
                    while endOfString.pointee != 0 && endOfString < end {
                        endOfString = endOfString.successor()
                    }
                    
                    if endOfString >= end { return nil }
                    // endOfString now points to the end of the string
                    
                    ptr = endOfString.successor()
                    return String(cString: startOfString)
                })
            }
    }
    
    public var objcEnumerationImage: ObjCEnumerationImage { .machHeader(self.pointer) }
    
    public var objcClasses: ObjCClassList {
        return objc_enumerateClasses(fromImage: self.objcEnumerationImage)
    }
    
}
