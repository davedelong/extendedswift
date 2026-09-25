//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/10/23.
//

import Foundation
import CoreServices

public typealias Spotlight = NSMetadataQuery

extension Spotlight {
    public struct SearchScope: RawRepresentable, Sendable {
        #if os(macOS)
        public static let homeDirectory = SearchScope(rawValue: NSMetadataQueryUserHomeScope)
        public static let local = SearchScope(rawValue: NSMetadataQueryLocalComputerScope)
        public static let network = SearchScope(rawValue: NSMetadataQueryNetworkScope)
        public static let localIndexed = SearchScope(rawValue: NSMetadataQueryIndexedLocalComputerScope)
        public static let networkIndexed = SearchScope(rawValue: NSMetadataQueryIndexedNetworkScope)
        #endif
        public static let iCloudDocuments = SearchScope(rawValue: NSMetadataQueryUbiquitousDocumentsScope)
        public static let iCloudData = SearchScope(rawValue: NSMetadataQueryUbiquitousDataScope)
        public static let externalICloudDocuments = SearchScope(rawValue: NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope)
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct Item: Sendable {
        nonisolated(unsafe) private let values: Dictionary<String, Any>
                
        /// Returns the value for the specified attribute of the receiver.
        public func value(forAttribute key: String) -> Any? { values[key] }
        
        /// Returns a dictionary containing the specified attributes and their values.
        public func values(forAttributes keys: [String]) -> [String : Any]? {
            let uniqued = keys.uniqued()
            return Dictionary(uniqueKeysWithValues: uniqued.compactMap { key -> (String, Any)? in
                guard let value = self.values[key] else { return nil }
                return (key, value)
            })
        }
        
        /// An array containing the attributes of the receiver.
        public var attributes: [String] { Array(values.keys) }
        
        fileprivate init(item: NSMetadataItem) {
            let allKeys = item.mdAttributeNames
            self.values = item.values(forAttributes: allKeys) ?? [:]
        }
    }
    
    public enum Result {
        case added(Item)
        case removed(Item)
        case updated(Item)
    }
    
    public var items: AnyAsyncSequence<Item> {
        let stream = AsyncStream { continuation in
            let delegate = SpotlightDelegate(query: self, provideContinuousUpdates: false, continuation: continuation)
            self.delegate = delegate
            self.start()
        }
        
        let compacted = stream.compactMap { result -> Item? in
            if case .added(let item) = result { return item }
            return nil
        }
            
        return compacted.eraseToAnySequence()
    }
}

public struct SpotlightQuery: AsyncSequence {
    public typealias Element = Spotlight.Item
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    public var scopes = Array<Spotlight.SearchScope>()
    public var predicate: NSPredicate
    public var sortDescriptors = Array<SortDescriptor<NSMetadataItem>>()
    
    public init(scopes: Array<Spotlight.SearchScope> = [], predicate: NSPredicate, sortDescriptors: Array<SortDescriptor<NSMetadataItem>> = []) {
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

extension NSMetadataItem {
    
    fileprivate var mdAttributeNames: [String] {
        guard let raw = self.value(forKey: "_item") else { return [] }
        let mdItem = (raw as! MDItem)
        let cfArray = MDItemCopyAttributeNames(mdItem)
        return (cfArray as? [String]) ?? []
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
            continuation.yield(.added(.init(item: mdItem)))
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
        for item in addedItems ?? [] { continuation.yield(.added(.init(item: item))) }
        
        let removedItems = note.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? Array<NSMetadataItem>
        for item in removedItems ?? [] { continuation.yield(.removed(.init(item: item))) }
        
        let changedItems = note.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? Array<NSMetadataItem>
        for item in changedItems ?? [] { continuation.yield(.updated(.init(item: item))) }
    }
    
}
