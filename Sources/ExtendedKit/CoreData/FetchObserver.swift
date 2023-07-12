//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import CoreData
import Combine

public class FetchObserver<T: Fetchable>: ObservableObject {
    
    public let objectWillChange: ObservableObjectPublisher
    public let objectDidChange: ObservableObjectPublisher
    
    private var core: _QueryCore<T>
    
    public var initialFilter: T.Filter { core.baseFilter }
    
    public var filter: T.Filter {
        get { core.filter }
        set { core.filter = newValue }
    }
    
    public var managedObjectContext: NSManagedObjectContext? {
        get { core.context }
        set { core.context = newValue }
    }
    
    public var results: FetchResults<T> { core.results }
    
    public var autoUpdates: Bool {
        get { core.autoupdates }
        set { core.autoupdates = newValue }
    }
    
    public init(filter: T.Filter, context: NSManagedObjectContext?) {
        let willChange = ObservableObjectPublisher()
        let didChange = ObservableObjectPublisher()
        
        self.objectWillChange = willChange
        self.objectDidChange = didChange
        self.core = _QueryCore(filter: filter, willChange: willChange, didChange: didChange)
        self.core.context = context
    }
    
}

private class _QueryCore<T: Fetchable>: NSObject, NSFetchedResultsControllerDelegate {
    
    private let willChange: ObservableObjectPublisher
    private let didChange: ObservableObjectPublisher
    
    private var _frc: NSFetchedResultsController<T.Filter.ResultType>?
    
    private var _results: FetchResults<T>?
    
    var results: FetchResults<T> {
        fetchIfNecessary()
        return _results ?? FetchResults()
    }
    
    init(filter: T.Filter, willChange: ObservableObjectPublisher, didChange: ObservableObjectPublisher) {
        self.baseFilter = filter
        self.filter = filter
        self.willChange = willChange
        self.didChange = didChange
        self.filter = filter
        self.autoupdates = true
        
        super.init()
    }
    
    let baseFilter: T.Filter
    
    var filter: T.Filter {
        didSet {
            // changing the filter does NOT require re-creating the FRC
            if filter != oldValue { reset(includingFRC: false) }
        }
    }
    
    var context: NSManagedObjectContext? {
        didSet {
            // changing the context requires re-creating the entire FRC
            if context != oldValue { reset(includingFRC: true) }
        }
    }
    
    private var hasPendingUpdates = false
    
    var autoupdates: Bool {
        didSet {
            if autoupdates && hasPendingUpdates { reset(includingFRC: false) }
        }
    }
    
    private func reset(includingFRC: Bool) {
        if autoupdates == false {
            hasPendingUpdates = true
        } else {
            willChange.send()
            _results = nil
        }
        
        if includingFRC { _frc = nil }
    }
    
    func fetchIfNecessary() {
        
        guard let context else {
            print("FetchObserver<\(T.self)> is missing its ManagedObjectContext")
            return
        }
        
        guard autoupdates == true || _results == nil || hasPendingUpdates == true else { return }
        
        hasPendingUpdates = false
        
        var request: NSFetchRequest<T.Filter.ResultType>?
        
        if _frc?.managedObjectContext != context {
            let fr = filter.fetchRequest()
            fr.fetchBatchSize = 25
            _frc = NSFetchedResultsController(fetchRequest: fr,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: nil, cacheName: nil)
            _frc?.delegate = self
            request = fr
        } else {
            request = _frc?.fetchRequest
        }
        
        if _results == nil {
            let r = request ?? filter.fetchRequest()
            _frc?.fetchRequest.update(toMatch: r)
            
            try! _frc?.performFetch()
            let resultsArray: NSArray = (_frc?.fetchedObjects as NSArray?) ?? NSArray()
            _results = FetchResults(results: resultsArray, context: context)
            didChange.send()
        }
        
    }
    
    // live updates
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if autoupdates == true {
            willChange.send()
        } else {
            hasPendingUpdates = true
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard autoupdates == true else { return }
        
        let objects = (controller.fetchedObjects as NSArray?) ?? NSArray()
        _results = FetchResults<T>(results: objects, context: controller.managedObjectContext)
        didChange.send()
    }
}
