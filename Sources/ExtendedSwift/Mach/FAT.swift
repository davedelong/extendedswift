//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/30/23.
//

import Foundation

public struct FAT {
    
    public let headers: Array<Mach.Header>
    
    public init?(contentsOf path: Path) {
        guard let data = try? Data(contentsOf: path) else { return nil }
        
        let fatSlices = data.withUnsafeBytes { buffer -> Array<Mach.Header> in
            guard let base = buffer.baseAddress else { return [] }
            
            let fatPointer = base.assumingMemoryBound(to: fat_header.self)
            
            let magic = fatPointer.pointee.magic
            guard magic == FAT_MAGIC || magic == FAT_CIGAM || magic == FAT_MAGIC_64 || magic == FAT_CIGAM_64 else {
                return []
            }
            
            let is32Bit = magic == FAT_CIGAM || magic == FAT_MAGIC
            
            // "All structures … are always writted and read in big-endian order"
            let numberOfSlices = fatPointer.pointee.nfat_arch.bigEndian
            
            var headers = Array<Mach.Header>()
            
            var headerPointer = base.advanced(by: MemoryLayout<fat_header>.size)
            let archSize = is32Bit ? MemoryLayout<fat_arch>.size : MemoryLayout<fat_arch_64>.size
            
            for _ in 0 ..< numberOfSlices {
                let machHeader: Mach.Header?
                
                if is32Bit {
                    let archPointer = headerPointer.assumingMemoryBound(to: fat_arch.self)
                    let offset = archPointer.pointee.offset.bigEndian
                    let start = base.advanced(by: Int(offset))
                    machHeader = Mach.Header(rawValue: start.assumingMemoryBound(to: mach_header.self), slide: 0)
                } else {
                    let archPointer = headerPointer.assumingMemoryBound(to: fat_arch_64.self)
                    let offset = archPointer.pointee.offset.bigEndian
                    let start = base.advanced(by: Int(offset))
                    machHeader = Mach.Header(rawValue: start.assumingMemoryBound(to: mach_header.self), slide: 0)
                }
                
                if let machHeader {
                    headers.append(machHeader)
                }
                
                headerPointer = headerPointer.advanced(by: archSize)
            }
            
            return headers
        }
        
        if fatSlices.isEmpty {
            // maybe this isn't a fat file; try to read the single architecture
            let potentialHeader = data.withUnsafeBytes { buffer -> Mach.Header? in
                guard let base = buffer.baseAddress else { return nil }
                let headerPointer = base.assumingMemoryBound(to: mach_header.self)
                return Mach.Header(rawValue: headerPointer, slide: 0)
            }
            
            if let potentialHeader {
                self.headers = [potentialHeader]
            } else {
                // no fat headers, no mach headers
                return nil
            }
            
        } else {
            self.headers = fatSlices
        }
    }
    
}
