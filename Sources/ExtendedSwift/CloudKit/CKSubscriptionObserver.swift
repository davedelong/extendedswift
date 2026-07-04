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

@MainActor
public class CKSubscriptionObserver: ObservableObject {
    
    private let database: CKDatabase
    private let timerInterval: TimeInterval
    private var sink: AnyCancellable?
    
    public let objectDidChange = ObservableObjectPublisher()
    public private(set) var isSearching = false
    public private(set) var results = Array<CKSubscription>()
    public private(set) var mostRecentError: Error?
    
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
    
    private func performChange(_ action: () -> Void) {
        self.objectWillChange.send()
        action()
        self.objectDidChange.send()
    }
    
    @MainActor
    public func refresh() async {
        if self.isSearching == true { return }
        
        self.performChange {
            self.isSearching = true
            self.sink?.cancel()
            self.sink = nil
        }
        
        do {
            let subs = try await self.database.allSubscriptions()
            self.performChange {
                if subs != self.results { self.results = subs }
                self.mostRecentError = nil
                self.isSearching = false
            }
        } catch {
            self.performChange {
                self.mostRecentError = error
                self.isSearching = false
            }
        }
        
        self.rescheduleTimer()
    }
    
    public func triggerRefresh() {
        Task { await refresh() }
    }
    
}

#endif
