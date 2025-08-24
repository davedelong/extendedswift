//
//  Collection+Async.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/24/25.
//

extension Collection {
    
    public func mapAsync<T, E: Error>(_ transform: (Element) async throws(E) -> T) async throws(E) -> Array<T> {
        var mapped = Array<T>()
        for item in self {
            mapped.append(try await transform(item))
        }
        return mapped
    }
    
    public func compactMapAsync<T, E: Error>(_ transform: (Element) async throws(E) -> T?) async throws(E) -> Array<T> {
        var mapped = Array<T>()
        for item in self {
            if let newItem = try await transform(item) {
                mapped.append(newItem)
            }
        }
        return mapped
    }
    
    public func filterAsync<E: Error>(_ include: (Element) async throws(E) -> Bool) async throws(E) -> Array<Element> {
        var filtered = Array<Element>()
        for item in self {
            if try await include(item) {
                filtered.append(item)
            }
        }
        return filtered
    }
    
    
}
