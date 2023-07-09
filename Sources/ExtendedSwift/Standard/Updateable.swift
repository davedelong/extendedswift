//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation

public protocol Updateable: AnyObject { }

extension NSObject: Updateable { }

extension Updateable /*where Self: NSObject*/ {
    public func update<V: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, V?>, to value: V) {
        updateObj(self, keyPath: keyPath, value: value)
    }
    
    public func update<V: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, V>, to value: V) {
        updateObj(self, keyPath: keyPath, value: value)
    }
}

private func updateObj<T: Updateable, V: Equatable>(_ obj: T, keyPath: ReferenceWritableKeyPath<T, V?>, value: V) {
    if let existing = obj[keyPath: keyPath], existing == value { return }
    obj[keyPath: keyPath] = value
}

private func updateObj<T: Updateable, V: Equatable>(_ obj: T, keyPath: ReferenceWritableKeyPath<T, V>, value: V) {
    if obj[keyPath: keyPath] != value {
        obj[keyPath: keyPath] = value
    }
}
