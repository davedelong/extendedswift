//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension KeyPath {
    
    public static prefix func !(rhs: KeyPath<Root, Value>) -> KeyPath<Root, Value> where Value == Bool {
        return rhs.appending(path: \.negated) as! KeyPath<Root, Value>
    }
    
}
