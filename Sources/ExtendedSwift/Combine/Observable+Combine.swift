//
//  Observable.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/31/25.
//

#if canImport(Observation)
import Observation
import Combine

@available(iOS 17, macOS 14, *)
extension Observable where Self: AnyObject {
    @MainActor public var publishers: Publishers<Self> { Publishers(object: self) }
    
    @MainActor
    public func publisher<V: Equatable>(for keyPath: KeyPath<Self, V>) -> AnyPublisher<V, Never> {
        let initialValue = self[keyPath: keyPath]
        let subject = CurrentValueSubject<V, Never>(initialValue)
        let trackedState = Tracked(object: self, keyPath: keyPath, subject: subject)
        track(trackedState)
        return subject.removeDuplicates().eraseToAnyPublisher()
    }
    
    @_disfavoredOverload
    @MainActor
    public func publisher<V>(for keyPath: KeyPath<Self, V>) -> AnyPublisher<V, Never> {
        let initialValue = self[keyPath: keyPath]
        let subject = CurrentValueSubject<V, Never>(initialValue)
        let trackedState = Tracked(object: self, keyPath: keyPath, subject: subject)
        track(trackedState)
        return subject.eraseToAnyPublisher()
    }
}

@available(iOS 17, macOS 14, *)
@dynamicMemberLookup
@MainActor
public struct Publishers<O: Observable & AnyObject> {
    fileprivate let object: O
    
    public subscript<V: Equatable>(dynamicMember keyPath: KeyPath<O, V>) -> AnyPublisher<V, Never> {
        return object.publisher(for: keyPath)
    }
    
    @_disfavoredOverload
    public subscript<V>(dynamicMember keyPath: KeyPath<O, V>) -> AnyPublisher<V, Never> {
        return object.publisher(for: keyPath)
    }
    
}

/*
 `withObservationTracking` only fires *once* the next time the property in the first closure is about to be mutated
 if you want continuous tracking, then after it has mutated, you need to call `withObservationTracking` *again*

 Also, the `onChange:` parameter fires *before* the property will be mutated, so we have to start a Task (ie,
 dispatch async) to retrieve the value *after* it has actually changed. We can then send the value to the publisher
 and initiate the next request for tracking'
 
 The Tracked<O, V> class is needed to work around the concurrency checking of the withObservationTracking function
*/

@available(iOS 17, macOS 14, *)
@MainActor
private func track<O: AnyObject, V>(_ trackedState: Tracked<O, V>) {
    withObservationTracking({
        guard let object = trackedState.object else { return }
        let _ = object[keyPath: trackedState.keyPath]
    }, onChange: {
        Task { @MainActor in
            guard let object = trackedState.object else { return }
            let newValue = object[keyPath: trackedState.keyPath]
            trackedState.subject.send(newValue)

            track(trackedState)
        }
    })
}

@MainActor
private class Tracked<O: AnyObject, V> {
    weak var object: O?
    let keyPath: KeyPath<O, V>
    let subject: CurrentValueSubject<V, Never>
    
    init(object: O?, keyPath: KeyPath<O, V>, subject: CurrentValueSubject<V, Never>) {
        self.object = object
        self.keyPath = keyPath
        self.subject = subject
    }
}

#endif
