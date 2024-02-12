//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension KeyPath {

    public static prefix func !(rhs: KeyPath<Root, Bool>) -> KeyPath<Root, Bool> {
        rhs.appending(path: \.negated)
    }

}
