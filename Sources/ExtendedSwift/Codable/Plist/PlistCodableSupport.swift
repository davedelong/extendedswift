//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/25/23.
//

import Foundation

internal let PlistNullValue = "ExtendedSwift.PlistCoding.NULL"

internal protocol PlistWriter {
    func write(value: Any)
}

internal class PlistRootWriter: PlistWriter {
    var encoded: Any?
    
    init() { }
    
    func write(value: Any) {
        encoded = value
    }
    
}
