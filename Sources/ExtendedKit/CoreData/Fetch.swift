//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct Fetch<T: Fetchable>: DynamicProperty {
    @Environment(\.managedObjectContext) var context
    
    @StateObject private var observer: FetchObserver<T>
    
    private let transaction: Transaction
    public let baseFilter: T.Filter
    
    public var autoupdates: Bool {
        get { observer.autoUpdates }
        nonmutating set { observer.autoUpdates = newValue }
    }
    
    public var autoupdateBinding: Binding<Bool> {
        Binding(get: { observer.autoUpdates },
                set: { observer.autoUpdates = $0 })
    }
    
    public var wrappedValue: FetchResults<T> {
        observer.results
    }
    
    public var filter: T.Filter {
        get { observer.filter }
        nonmutating set { observer.filter = newValue }
    }
    
    public var projectedValue: Binding<T.Filter> {
        return Binding(get: { self.filter },
                       set: { self.filter = $0 })
    }
    
    public init(_ filter: T.Filter, animation: Animation? = nil) {
        _observer = StateObject(wrappedValue: FetchObserver<T>(filter: filter, context: nil))
        
        self.baseFilter = filter
        self.transaction = Transaction(animation: animation)
    }
    
    public mutating func update() {
        observer.withoutPublishingChanges {
            $0.managedObjectContext = self.context
        }
        _ = observer.results // trigger a fetch (if necessary) by calling .results
    }
}
