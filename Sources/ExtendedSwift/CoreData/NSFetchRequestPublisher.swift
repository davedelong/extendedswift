//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/19/23.
//

import Foundation
import Combine
import CoreData

extension NSManagedObjectContext {
    
    public func publisher<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>) -> NSFetchRequestPublisher<T> {
        return NSFetchRequestPublisher(fetchRequest: fetchRequest, context: self)
    }
    
}

public struct NSFetchRequestPublisher<T: NSFetchRequestResult>: Publisher {
    public typealias Output = Array<T>
    public typealias Failure = Error
    
    public var fetchRequest: NSFetchRequest<T>
    public var context: NSManagedObjectContext
    
    public init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.context = context
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = NSFetchRequestSubscription(fetchRequest: fetchRequest, context: context, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

private class NSFetchRequestSubscription<T: NSFetchRequestResult>: NSObject, Subscription, NSFetchedResultsControllerDelegate {
    
    private var fetchRequest: NSFetchRequest<T>
    private var context: NSManagedObjectContext
    private var observer: NSFetchedResultsController<T>?
    
    private var send: (Result<Array<T>, Error>) -> Subscribers.Demand
    private var totalDemand = Subscribers.Demand.none {
        didSet { updateBasedOnNewDemand() }
    }
    
    init<S: Subscriber>(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext, subscriber: S) where S.Input == Array<T>, S.Failure == Error {
        self.fetchRequest = fetchRequest
        self.context = context
        self.send = { subscriber.receive($0) }
    }
    
    func request(_ demand: Subscribers.Demand) {
        totalDemand += demand
    }
    
    func cancel() {
        totalDemand = .none
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard controller == self.observer else { return }
        guard totalDemand > 0 else { return }
        self.processFetchedObjects()
    }
    
    private func updateBasedOnNewDemand() {
        if totalDemand > 0  && observer == nil {
            // create the observer if necessary
            
            self.observer = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.observer?.delegate = self
            
            do {
                try context.performAndWait {
                    try self.observer?.performFetch()
                }
                self.processFetchedObjects()
            } catch {
                totalDemand = self.send(.failure(error))
            }
            
        }
        
        // this is a separate if statement, because setting up the observer and sending initial values
        // might cause the demand to drop back to zero, which should reset the observer
        if totalDemand == .none {
            observer?.delegate = nil
            observer = nil
        }
    }
    
    private func processFetchedObjects() {
        let objects = self.observer?.fetchedObjects
        totalDemand = self.send(.success(objects ?? []))
    }
    
}
