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

public class CKSubscriptionObserver: ObservableObject {
    
    private let database: CKDatabase
    private let timerInterval: TimeInterval
    private var sink: AnyCancellable?
    
    @Published public private(set) var isSearching = false
    
    @Published public private(set) var results = Array<CKSubscription>()
    @Published public private(set) var mostRecentError: Error?
    
    public init(database: CKDatabase, refreshInterval: TimeInterval = 60) {
        self.database = database
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
            let all = try await self.database.allSubscriptions()
            self.mostRecentError = nil
            if all != self.results {
                self.results = all
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
    
}

#endif
