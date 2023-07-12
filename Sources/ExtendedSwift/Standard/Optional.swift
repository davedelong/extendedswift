//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation

extension Optional {
    
    public var unwrapped: Wrapped {
        return self !! "Cannot unwrap nil \(Self.self)"
    }
    
}
