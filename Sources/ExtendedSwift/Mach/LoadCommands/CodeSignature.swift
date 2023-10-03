//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/1/23.
//

import Foundation

extension Mach {
    
    public struct CodeSignature: MachLoadCommand {
        public let header: Mach.Header
        public let pointer: UnsafePointer<load_command>
        
        public init?(header: Mach.Header, pointer: UnsafePointer<load_command>) {
            self.header = header
            self.pointer = pointer
            
            guard self.commandType == .codeSignature else { return nil }
        }
        
        public var dataSize: UInt32 {
            let ptr = pointer.rebound(to: linkedit_data_command.self)
            return ptr.pointee.datasize.swapping(header.needsSwapping)
        }
        
        public var dataPointer: UnsafeRawPointer? {
            guard dataSize > 0 else { return nil }
            
            let ptr = pointer.rebound(to: linkedit_data_command.self)
            let offset = ptr.pointee.dataoff.swapping(header.needsSwapping)
            return header.pointer.advanced(by: Int(offset))
        }
        
        public var codeSignature: Dictionary<String, Any>? {
            guard let dataPointer else { return nil }
            
            var signature = Dictionary<String, Any>()
            signature["ARCH"] = "CPU type: (\(header.cpuType),\(header.cpuSubType))"
            
            // lc_code_sig reads from dataPointer

            let superBlob = dataPointer.assumingMemoryBound(to: SuperBlob.self)
            guard superBlob.pointee.magic.bigEndian == CSMAGIC_EMBEDDED_SIGNATURE else {
                return nil
            }
            
            let indexPointer = dataPointer.advanced(by: MemoryLayout<SuperBlob>.size)
            let indexBuffer = UnsafeBufferPointer(start: indexPointer.assumingMemoryBound(to: BlobIndex.self),
                                                  count: Int(superBlob.pointee.count.bigEndian))
            
            for index in indexBuffer {
                let offset = index.offset.bigEndian
                let blobStart = dataPointer.advanced(by: Int(offset))
                let blobHeader = blobStart.assumingMemoryBound(to: BlobHeader.self)
                
                let magic = blobHeader.pointee.magic.bigEndian
                let length = blobHeader.pointee.length.bigEndian
                
                switch magic {
                    case CSMAGIC_REQUIREMENTS:
                        //write_data("requirements", bytes, length);
                        break;
                    case CSMAGIC_CODEDIRECTORY:
                        //write_data("codedir", bytes, length);
                        let cd = blobStart.assumingMemoryBound(to: CS_CodeDirectory.self)
                        guard cd.pointee.version.bigEndian >= 0x20001 else { break }
                        guard cd.pointee.version.bigEndian <= 0x2F000 else { break }
                        guard cd.pointee.hashSize.bigEndian == 20 else { break }
                        guard cd.pointee.hashType.bigEndian == 1 else { break }
                        
                        let codeDir = Data(pointer: blobStart, count: Int(length))
                        signature["CodeDirectory"] = codeDir
                        
                        let hashOffset = cd.pointee.hashOffset.bigEndian
                        let hashSize = cd.pointee.hashSize.bigEndian
                        let entitlementSlot: UInt32 = 5
                        
                        if cd.pointee.nSpecialSlots.bigEndian >= entitlementSlot {
                            let ptr = blobStart.advanced(by: Int(hashOffset)).advanced(by: -Int(entitlementSlot * UInt32(hashSize)))
                            
                            let data = Data(pointer: ptr, count: Int(hashSize))
                            signature["EntitlementsCDHash"] = data
                        }
                    case 0xfade0b01:
                        //write_data("signed", lc_code_signature, bytes-lc_code_signature);
                        guard length > 8 else { break }
                        signature["SignedData"] = Data(pointer: blobStart.advanced(by: 8),
                                                       count: Int(length - 8))
                    case 0xfade7171:
                        guard length > 8 else { break }
                        #warning("TODO: sha1 the blob")
                        signature["EntitlementsHash"] = nil // SHA1 of the entire blob
                        signature["Entitlements"] = Data(pointer: blobStart.advanced(by: 8),
                                                         count: Int(length - 8))
                    default:
                        break
                }
            }
            
            return signature
        }
        
        public var entitlementsData: Data? {
            return self.codeSignature?["Entitlements"] as? Data
        }
        
        public var entitlements: Dictionary<String, Any>? {
            guard let data = entitlementsData else { return nil }
            let obj = try? PropertyListSerialization.propertyList(from: data, format: nil)
            return obj as? Dictionary<String, Any>
        }
    }
    
}

// adapted from https://github.com/apple-oss-distributions/Security/blob/main/SecurityTool/sharedTool/codesign.c

/*
 * Structures of an embedded signature
 *
 * the structures always use big endianness
 * the .c file linked above uses ntohl() to swap the numbers
 * from big endian to host endian
 */

private let CSMAGIC_REQUIREMENT: UInt32    = 0xfade0c00        /* single Requirement blob */
private let CSMAGIC_REQUIREMENTS: UInt32 = 0xfade0c01        /* Requirements vector (internal requirements) */
private let CSMAGIC_CODEDIRECTORY: UInt32 = 0xfade0c02        /* CodeDirectory blob */
private let CSMAGIC_EMBEDDED_SIGNATURE: UInt32 = 0xfade0cc0 /* embedded form of signature data */
private let CSSLOT_CODEDIRECTORY: UInt32 = 0                /* slot index for CodeDirectory */

private struct SuperBlob {
    let magic: UInt32 /* magic number */
    let length: UInt32 /* total length of SuperBlob */
    let count: UInt32 /* number of index entries following */
    /* followed by \(count) BlobIndexes in no particular order as indicated by offsets in index */
}

private struct BlobIndex {
    let type: UInt32
    let offset: UInt32
}

private struct BlobHeader {
    let magic: UInt32
    let length: UInt32
}

private struct CS_CodeDirectory {
    let magic: UInt32                    /* magic number (CSMAGIC_CODEDIRECTORY) */
    let length: UInt32                /* total length of CodeDirectory blob */
    let version: UInt32                /* compatibility version */
    let flags: UInt32                    /* setup and mode flags */
    let hashOffset: UInt32            /* offset of hash slot element at index zero */
    let identOffset: UInt32            /* offset of identifier string */
    let nSpecialSlots: UInt32            /* number of special hash slots */
    let nCodeSlots: UInt32            /* number of ordinary (code) hash slots */
    let codeLimit: UInt32                /* limit to main image signature range */
    let hashSize: UInt8                /* size of each hash in bytes */
    let hashType: UInt8                /* type of hash (cdHashType* constants) */
    let spare1: UInt8                    /* unused (must be zero) */
    let pageSize: UInt8                /* log2(page size in bytes); 0 => infinite */
    let spare2: UInt32                /* unused (must be zero) */
    /* followed by dynamic content as located by offset fields above */
}
