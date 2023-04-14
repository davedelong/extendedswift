//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/10/23.
//

import Foundation

public typealias Spotlight = NSMetadataQuery

extension Spotlight {
    public struct SearchScope: RawRepresentable {
        public static let homeDirectory = SearchScope(rawValue: NSMetadataQueryUserHomeScope)
        public static let local = SearchScope(rawValue: NSMetadataQueryLocalComputerScope)
        public static let network = SearchScope(rawValue: NSMetadataQueryNetworkScope)
        public static let localIndexed = SearchScope(rawValue: NSMetadataQueryIndexedLocalComputerScope)
        public static let networkIndexed = SearchScope(rawValue: NSMetadataQueryIndexedNetworkScope)
        public static let iCloudDocuments = SearchScope(rawValue: NSMetadataQueryUbiquitousDocumentsScope)
        public static let iCloudData = SearchScope(rawValue: NSMetadataQueryUbiquitousDataScope)
        public static let externalICloudDocuments = SearchScope(rawValue: NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope)
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public enum Result {
        case added(NSMetadataItem)
        case removed(NSMetadataItem)
        case updated(NSMetadataItem)
    }
    
    public var items: AnyAsyncSequence<NSMetadataItem> {
        let stream = AsyncStream { continuation in
            let delegate = SpotlightDelegate(query: self, provideContinuousUpdates: false, continuation: continuation)
            self.delegate = delegate
            self.start()
        }
        
        let compacted = stream.compactMap { result -> NSMetadataItem? in
            if case .added(let item) = result { return item }
            return nil
        }
            
        return compacted.eraseToAnySequence()
    }
}

public struct SpotlightQuery: AsyncSequence {
    public typealias Element = NSMetadataItem
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    public var scopes = Array<Spotlight.SearchScope>()
    public var predicate: NSPredicate
    public var sortDescriptors = Array<SortDescriptor<Element>>()
    
    public init(scopes: Array<Spotlight.SearchScope> = [], predicate: NSPredicate, sortDescriptors: Array<SortDescriptor<Element>> = []) {
        self.scopes = scopes
        self.predicate = predicate
    }
    
    public func makeAsyncIterator() -> AnyAsyncIterator<Element> {
        let q = NSMetadataQuery()
        q.searchScopes = scopes.map(\.rawValue)
        q.predicate = predicate
        q.sortDescriptors = sortDescriptors.map { NSSortDescriptor($0) }
        
        return q.items.makeAsyncIterator()
    }
    
}

private class SpotlightDelegate: NSObject, NSMetadataQueryDelegate {
    private var retainQuery: NSMetadataQuery?
    private var retainSelf: SpotlightDelegate?
    private let continuousUpdates: Bool
    private let continuation: AsyncStream<Spotlight.Result>.Continuation
    
    init(query: NSMetadataQuery, provideContinuousUpdates: Bool, continuation: AsyncStream<Spotlight.Result>.Continuation) {
        self.continuousUpdates = provideContinuousUpdates
        self.continuation = continuation
        super.init()
        
        self.retainQuery = query
        self.retainSelf = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didStopGathering(_:)),
                                               name: .NSMetadataQueryDidFinishGathering,
                                               object: query)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateResults(_:)),
                                               name: .NSMetadataQueryDidUpdate,
                                               object: query)
    }
    
    @objc func didStopGathering(_ note: Notification) {
        let query = note.object as? NSMetadataQuery !! "Bad notification"
        
        for idx in 0 ..< query.resultCount {
            guard let mdItem = query.result(at: idx) as? NSMetadataItem else { continue }
            continuation.yield(.added(mdItem))
        }
        
        if self.continuousUpdates {
            query.enableUpdates()
        } else {
            query.stop()
            continuation.finish()
            self.retainSelf = nil
            self.retainQuery = nil
        }
    }
    
    @objc func didUpdateResults(_ note: Notification) {
        let addedItems = note.userInfo?[NSMetadataQueryUpdateAddedItemsKey] as? Array<NSMetadataItem>
        for item in addedItems ?? [] { continuation.yield(.added(item)) }
        
        let removedItems = note.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? Array<NSMetadataItem>
        for item in removedItems ?? [] { continuation.yield(.removed(item)) }
        
        let changedItems = note.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? Array<NSMetadataItem>
        for item in changedItems ?? [] { continuation.yield(.updated(item)) }
    }
    
}
