//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/8/23.
//

import Foundation

extension NSLocking {
    
    public func withLock<T>(_ perform: () -> T) -> T {
        self.lock()
        let result = perform()
        self.unlock()
        return result
    }
    
}
