//
//  File.swift
//  
//
//  Created by Dave DeLong on 1/2/24.
//

import Foundation
import SwiftUI

// source: https://gist.github.com/IanKeen/a85e4ed74a10a25341c44a98f43cf386
// note: originally called "Transaction", but there's already a SwiftUI type with that name

@propertyWrapper
@dynamicMemberLookup
public struct Staged<Value>: DynamicProperty {
    
    @State private var derived: Value
    @Binding private var source: Value
    
    fileprivate init(source: Binding<Value>) {
        self._source = source
        self._derived = State(wrappedValue: source.wrappedValue)
    }

    public var wrappedValue: Value {
        get { derived }
        nonmutating set { derived = newValue }
    }

    public var projectedValue: Staged<Value> { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        return $derived[dynamicMember: keyPath]
    }

    public var binding: Binding<Value> { $derived }

    public func commit() {
        source = derived
    }
    
    public func revert() {
        derived = source
    }
}

extension Staged where Value: Equatable {
    public var hasChanges: Bool { return source != derived }
}

extension Binding {
    public func staged() -> Staged<Value> { .init(source: self) }
}
