//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import Logging

extension Logger {
    
    public static func named(_ name: String) -> Logger {
        return namedLogs.with { existing in
            if let e = existing[name] { return e }
            let new = Logger(label: name)
            existing[name] = new
            return new
        }
    }
    
}

private let namedLogs = Atomic<Dictionary<String, Logger>>([:])
