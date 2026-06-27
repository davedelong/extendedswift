//
//  FSPublisher.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/5/22.
//

import Foundation
import Combine

#if os(macOS)

public struct FSPublisher: Publisher {
    public typealias Output = FSEvent
    public typealias Failure = Never
    
    public var path: Path
    
    public init(path: Path) {
        self.path = path
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = FSSubscription(path: path, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

private class FSSubscription: Subscription {
    private let path: Path
    private var watcher: FSWatcher?
    
    private let sendToSubscriber: (FSPublisher.Output) -> Subscribers.Demand
    private var currentDemand: Subscribers.Demand = .none
    
    init<T: Subscriber>(path: Path, subscriber: T) where T.Input == FSPublisher.Output, T.Failure == FSPublisher.Failure {
        self.path = path
        self.sendToSubscriber = { subscriber.receive($0) }
    }
    
    deinit {
        cancel()
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.currentDemand += demand
        
        if currentDemand > 0 && watcher == nil {
            watcher = FSWatcher(path: self.path, report: { [weak self] event in
                self?.send(event)
            })
        }
    }
    
    func cancel() {
        watcher?.cancel()
        watcher = nil
        currentDemand = .none
    }
    
    fileprivate func send(_ event: FSEvent) {
        currentDemand = currentDemand - 1 - sendToSubscriber(event)
        if currentDemand <= .none { self.cancel() }
    }
}

#endif
