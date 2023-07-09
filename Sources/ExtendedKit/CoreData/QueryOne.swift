//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct QueryOne<T: Queryable>: DynamicProperty {
    @Query var inner: QueryResults<T>
    
    public var wrappedValue: T? { inner.first }
    
    public var filter: T.Filter {
        get { _inner.filter }
        nonmutating set { _inner.filter = newValue }
    }
    
    public var projectedValue: Binding<T.Filter> { _inner.projectedValue }
    public var autoupdateBinding: Binding<Bool> { _inner.autoupdateBinding }
    
    public init(_ filter: T.Filter, animation: Animation? = nil) {
        _inner = Query(filter, animation: animation)
    }
}
