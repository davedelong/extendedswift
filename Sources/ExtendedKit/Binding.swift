//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import Foundation
import ExtendedSwift
import SwiftUI

extension Binding {
    
    public func isNotNull<V>() -> Binding<Bool> where Value == Optional<V> {
        return Binding<Bool>(get: { self.wrappedValue != nil },
                             set: { _ in self.wrappedValue = nil })
    }
    
    public func map<V>(getter: @escaping (Value) -> V, setter: @escaping (V) -> Value) -> Binding<V> {
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
}

extension Binding where Value == Bool {
    
    public var negated: Binding<Bool> {
        return Binding(get: { !self.wrappedValue },
                       set: { self.wrappedValue = !$0 })
    }
    
}

extension Binding where Value: SetAlgebra {
    
    public func contains(_ element: Value.Element) -> Binding<Bool> {
        return Binding<Bool>(get: { self.wrappedValue[contains: element] },
                             set: { self.wrappedValue[contains: element] = $0 })
    }
    
}

private class Debouncer<Value> {
    let interval: TimeInterval
    let sender: (Value) -> Void
    
    private var current: DispatchWorkItem?
    
    init(interval: TimeInterval, sender: @escaping (Value) -> Void) {
        self.interval = interval
        self.sender = sender
    }
    
    func send(_ value: Value) {
        current?.cancel()
        let work = DispatchWorkItem(block: { self.sender(value) })
        self.current = work
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: work)
    }
    
}
