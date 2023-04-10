//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/10/23.
//

import Foundation
import Combine

extension RunLoop {
    
    public func onEveryTurn(perform work: @escaping () -> Void) -> Cancellable {
        
        let observer = CFRunLoopObserverCreateWithHandler(nil,
                                                          CFRunLoopActivity.entry.rawValue,
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
