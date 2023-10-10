//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/9/23.
//

import Foundation
import OSLog
import Logging

// based on https://www.pointfree.co/blog/posts/70-unobtrusive-runtime-warnings-for-libraries

extension Logging.Logger {
    
    @inline(__always)
    @_transparent
    public static func runtimeWarning(_ message: StaticString, _ category: String = "Warn", handle: UnsafeRawPointer = #dsohandle) {
        os_log(.fault,
               dso: Dyld.swiftUIPointer ?? handle,
               log: OSLog(
                 subsystem: "com.apple.runtime-issues",
                 category: category
               ),
               message
        )
    }
    
}

extension Dyld {
    
    public static var swiftUIPointer: UnsafeRawPointer? { _swiftUIInfo }
    
}

public let _swiftUIInfo: UnsafeRawPointer? = {
    // see if we can find the header manually
    if let images = Dyld.images.first(where: { $0.name.hasSuffix("SwiftUI") }) {
        return images.header.pointer
    }
    
    var info = Dl_info()
    let imagePointers = dlopen(nil, RTLD_LAZY)
    guard let symbol = dlsym(imagePointers, "$s7SwiftUI4ViewMp") else {
        return nil
    }
    
    let status = dladdr(symbol, &info)
    if status == 0 { return nil }
    guard let base = info.dli_fbase else { return nil }
    return UnsafeRawPointer(base)
}()
