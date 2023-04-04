//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension Bool {
    
    // useful in filtering, such as:
    // string.map(\.isNumber.negated)
    public var negated: Bool { !self }
    
    public func toggled() -> Bool { negated }
    
    public var isTrue: Bool { self == true }
    
    public var isFalse: Bool { self == false }
    
}
