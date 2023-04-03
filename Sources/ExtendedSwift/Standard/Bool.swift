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
    
}
