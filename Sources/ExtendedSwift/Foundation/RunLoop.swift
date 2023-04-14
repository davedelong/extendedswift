//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/10/23.
//

import Foundation
import Combine

extension RunLoop {
    
    public func onEntry(perform work: @escaping () -> Void) -> Cancellable {
        return self.on(.entry, perform: work)
    }
    
    public func onExit(perform work: @escaping () -> Void) -> Cancellable {
        return self.on(.exit, perform: work)
    }
    
    public func on(_ activity: CFRunLoopActivity, perform work: @escaping () -> Void) -> Cancellable {
        let observer = CFRunLoopObserverCreateWithHandler(nil,
                                                          activity.rawValue,
                                                          true,
                                                          0,
                                                          { _, _ in
            work()
        })
        
        let cf = self.getCFRunLoop()
        CFRunLoopAddObserver(cf, observer, CFRunLoopMode.defaultMode)
        
        return AnyCancellable({
            CFRunLoopPerformBlock(cf, CFRunLoopMode.defaultMode as CFTypeRef, {
                CFRunLoopRemoveObserver(cf, observer, CFRunLoopMode.defaultMode)
            })
        })
    }
    
}
