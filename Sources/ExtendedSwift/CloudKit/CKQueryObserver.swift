//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/24/23.
//

#if canImport(CloudKit)

import Foundation
import CloudKit
import Combine

public class CKQueryObserver: ObservableObject {
    
    public struct Configuration {
        public var database: CKDatabase
        public var query: CKQuery
        public var desiredKeys: Array<CKRecord.FieldKey>?
        public var zoneID: CKRecordZone.ID?
        public var fetchLimit: Int
        
        public init(database: CKDatabase, 
                    query: CKQuery,
                    desiredKeys: Array<CKRecord.FieldKey>? = nil,
                    zoneID: CKRecordZone.ID? = nil,
                    fetchLimit: Int = CKQueryOperation.maximumResults) {
            
            self.database = database
            self.query = query
            self.desiredKeys = desiredKeys
            self.zoneID = zoneID
            self.fetchLimit = fetchLimit
        }
    }
    
    public let configuration: Configuration
    
    private let timerInterval: TimeInterval
    private var sink: AnyCancellable?
    
    @Published public private(set) var isSearching = false
    
    @Published public private(set) var results = Array<CKRecord>()
    @Published public private(set) var mostRecentError: Error?
    
    public init(configuration: Configuration, refreshInterval: TimeInterval = 60) {
        self.configuration = configuration
        self.timerInterval = refreshInterval
        self.triggerRefresh()
    }
    
    private func rescheduleTimer() {
        sink = Timer.publish(every: timerInterval, tolerance: timerInterval/10, on: .main, in: .default, options: nil)
            .autoconnect()
            .sink(receiveValue: { [unowned self] _ in
                self.triggerRefresh()
            })
    }
    
    @MainActor
    public func refresh() async {
        if self.isSearching == true { return }
        
        self.isSearching = true
        self.sink?.cancel()
        self.sink = nil
        
        do {
            let all = try await self.fetchAllRecords()
            
            self.mostRecentError = nil
            let newResults = all.compactMap(\.success)
            
            if newResults != self.results {
                self.results = newResults
            }
        } catch {
            print("Error refreshing: \(error)")
            self.mostRecentError = error
        }
        
        self.isSearching = false
        self.rescheduleTimer()
    }
    
    public func triggerRefresh() {
        Task { await refresh() }
    }
    
    private func fetchAllRecords() async throws -> Array<Result<CKRecord, Error>> {
        var results = Array<Result<CKRecord, Error>>()
        
        let db = configuration.database
        let q = configuration.query
        let keys = configuration.desiredKeys
        let zoneID = configuration.zoneID
        
        var cursor: CKQueryOperation.Cursor?
        repeat {
            let intermediate: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let c = cursor {
                intermediate = try await db.records(continuingMatchFrom: c, desiredKeys: nil)
            } else {
                intermediate = try await db.records(matching: q, inZoneWith: zoneID, desiredKeys: keys, resultsLimit: configuration.fetchLimit)
            }
            
            results.append(contentsOf: intermediate.matchResults.map(\.1))
            
            if results.count >= configuration.fetchLimit && configuration.fetchLimit > 0 {
                cursor = nil
            } else {
                cursor = intermediate.queryCursor
            }
        } while cursor != nil
        
        if results.count > configuration.fetchLimit && configuration.fetchLimit > 0 {
            let overage = results.count - configuration.fetchLimit
            results.removeLast(overage)
        }
        
        return results
    }
    
}

#endif
