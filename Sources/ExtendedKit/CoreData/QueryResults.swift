//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import CoreData

public struct QueryResults<T: Queryable>: RandomAccessCollection {
    
    private class Cache {
        var storage = Dictionary<Int, T>()
    }
    
    private let results: NSArray
    private let context: NSManagedObjectContext?
    private var cache = Cache()
    
    internal init() {
        self.context = nil
        self.results = NSArray()
    }
    
    internal init(results: NSArray, context: NSManagedObjectContext) {
        self.context = context
        self.results = results
    }
    
    public var count: Int { results.count }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public var allValues: Array<T> {
        guard let context else { return [] }
        
        return context.performAndWait {
            (0 ..< count).map { self._onqueue_get(at: $0) }
        }
    }
    
    public subscript(position: Int) -> T {
        return context!.performAndWait {
            self._onqueue_get(at: position)
        }
    }
    
    private func _onqueue_get(at position: Int) -> T {
        if let e = cache.storage[position] { return e }
        let object = results.object(at: position) as! T.Filter.ResultType
        let built = T(result: object)
        cache.storage[position] = built
        return built
    }
}

