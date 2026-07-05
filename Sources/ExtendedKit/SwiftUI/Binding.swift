//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import Foundation
import ExtendedSwift
import SwiftUI
import Synchronization

extension Binding where Value: Sendable {
    
    public func equals(_ value: Value) -> Binding<Bool> where Value: Equatable {
        return Binding<Bool>(get: { self.wrappedValue == value },
                             set: { isOn in
            if isOn { self.wrappedValue = value }
        })
    }
    
    public func isNotNull<V>() -> Binding<Bool> where Value == Optional<V> {
        return Binding<Bool>(get: { self.wrappedValue != nil },
                             set: { _ in self.wrappedValue = nil })
    }
    
    public func map<V: Sendable>(getter: @escaping @Sendable (Value) -> V, setter: @escaping @Sendable (V) -> Value) -> Binding<V> {
        return Binding<V>(get: { getter(self.wrappedValue) },
                          set: { self.wrappedValue = setter($0) })
    }
    
    public func debounce(_ interval: TimeInterval) -> Binding<Value> {
        let bounce = Debouncer(interval: interval, sender: { self.wrappedValue = $0 })
        
        return Binding(get: { self.wrappedValue },
                       set: { bounce.send($0) })
        
    }
    
    public func contains<Element>(_ element: Element) -> Binding<Bool> where Value == Optional<Set<Element>> {
        return Binding<Bool>(get: { return self.wrappedValue?.contains(element) ?? false },
                             set: { present in
                                if present {
                                    self.wrappedValue = (self.wrappedValue ?? Set()).union([element])
                                } else {
                                    var current = self.wrappedValue
                                    current?.remove(element)
                                    if current?.isEmpty == true {
                                        self.wrappedValue = nil
                                    } else {
                                        self.wrappedValue = current
                                    }
                                }
                             })
    }
    
    public func onSet(willSet: @escaping @Sendable (_ oldValue: Value, _ newValue: Value) -> Void) -> Binding<Value> {
        return Binding(get: { wrappedValue },
                       set: { newValue in
            let oldValue = wrappedValue
            willSet(oldValue, newValue)
            wrappedValue = newValue
        })
    }
    
    public func onSet(didSet: @escaping @Sendable (_ oldValue: Value, _ newValue: Value) -> Void) -> Binding<Value> {
        return Binding(get: { wrappedValue },
                       set: { newValue in
            let oldValue = wrappedValue
            wrappedValue = newValue
            didSet(oldValue, newValue)
        })
    }
    
    public func onSet(willSet: @escaping @Sendable (_ oldValue: Value, _ newValue: Value) -> Void, didSet: @escaping @Sendable (_ oldValue: Value, _ newValue: Value) -> Void) -> Binding<Value> {
        return Binding(get: { wrappedValue },
                       set: { newValue in
            let oldValue = wrappedValue
            willSet(oldValue, newValue)
            wrappedValue = newValue
            didSet(oldValue, newValue)
        })
    }
}

extension Binding where Value == Bool {
    
    public var negated: Binding<Bool> {
        return Binding(get: { !self.wrappedValue },
                       set: { self.wrappedValue = !$0 })
    }
    
}

extension Binding where Value: SetAlgebra & Sendable {
    
    public func contains(_ element: Value.Element) -> Binding<Bool> where Value.Element: Sendable {
        return Binding<Bool>(get: { self.wrappedValue[contains: element] },
                             set: { self.wrappedValue[contains: element] = $0 })
    }
    
}

private final class Debouncer<Value: Sendable>: Sendable {
    let interval: TimeInterval
    let sender: @Sendable (Value) -> Void
    
    private let current = Mutex<DispatchWorkItem?>(nil)
    
    init(interval: TimeInterval, sender: @escaping @Sendable (Value) -> Void) {
        self.interval = interval
        self.sender = sender
    }
    
    func send(_ value: Value) {
        let newWork = current.withLock { old in
            old?.cancel()
            let new = DispatchWorkItem(block: { self.sender(value) })
            old = new
            return new
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: newWork)
    }
    
}
