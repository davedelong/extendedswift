//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension ProcessInfo {
    
    public var isDebuggerAttached: Bool {
    #if DEBUG
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let nameSize = UInt32(name.count)
        var info: kinfo_proc = kinfo_proc()
        var info_size = MemoryLayout<kinfo_proc>.size
        
        let success = sysctl(&name, nameSize, &info, &info_size, nil, 0) == 0
        
        if success && ((info.kp_proc.p_flag & P_TRACED) != 0) {
            return true
        }
    #endif
        
        return false
    }
    
}
