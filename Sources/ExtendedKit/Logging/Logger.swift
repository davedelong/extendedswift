//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import Logging
import Synchronization

extension Logger {
    
    public static func named(_ name: String) -> Logger {
        return namedLogs.withLock { existing in
            if let e = existing[name] { return e }
            let new = Logger(label: name)
            existing[name] = new
            return new
        }
    }
    
}

private let namedLogs = Mutex<Dictionary<String, Logger>>([:])
