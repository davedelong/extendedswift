//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation
private import PrivateAPI

extension ProcessInfo {
    
    public var isDebuggerAttached: Bool {
    #if DEBUG
        var name = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let nameSize = UInt32(name.count)
        var info: kinfo_proc = kinfo_proc()
        var info_size = MemoryLayout<kinfo_proc>.size
        
        let success = Darwin.sysctl(&name, nameSize, &info, &info_size, nil, 0) == 0
        
        if success && ((info.kp_proc.p_flag & P_TRACED) != 0) {
            return true
        }
    #endif
        return false
    }
    
    public var entitlementsDictionary: Dictionary<String, Any> { _entitlementsDict }
    
    public var entitlements: Entitlements { Entitlements(source: _entitlementsDict) }
    
    public static func entitlementsDictionary(for path: Path) -> Dictionary<String, Any>? {
        autoreleasepool {
            let fat = FAT(contentsOf: path)
            return fat?.headers.firstMap(\.entitlements)
        }
    }
    
    public var uname: String? {
        get throws {
            var systemInfo = utsname()
            let status = Darwin.uname(&systemInfo)
            guard status == 0 else {
                throw NSError(domain: "extendedswift.uname", code: Int(errno))
            }
            return withUnsafePointer(to: &systemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                    String(validatingCString: ptr)
                }
            }
        }
    }
    
    public func sysctl(name: String) throws -> String? {
        var size = 0
        let status = sysctlbyname(name, nil, &size, nil, 0)
        guard status == 0 else {
            throw NSError(domain: "extendedswift.sysctl", code: Int(errno), userInfo: [
                "name": name
            ])
        }
        guard size > 0 else { return nil }
        
        return String(unsafeUninitializedCapacity: size, initializingUTF8With: { umrbp in
            sysctlbyname(name, umrbp.baseAddress, &size, nil, 0)
            return size - 1 // ignore the trailing null byte
        })
    }
}

nonisolated(unsafe) private let _entitlementsDict: Dictionary<String, Any> = {
    let exe = Dyld.executable
    return exe.header.entitlements ?? [:]
}()
