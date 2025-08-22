//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

infix operator ?!: NilCoalescingPrecedence

public func ?! <T, E: Error>(lhs: T?, rhs: @autoclosure () -> E) throws(E) -> T {
    
    if let value = lhs {
        return value
    }
    
    throw rhs()
}

infix operator !!: NilCoalescingPrecedence

public func !! <T>(lhs: T?, rhs: @autoclosure () -> String) -> T {
    
    if let value = lhs {
        return value
    }
    
    fatalError("Error unwrapping value of type \(T.self): \(rhs())")
}

// public typealias None = Never
