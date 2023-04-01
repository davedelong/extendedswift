//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Result where Success: Collection {
    
    public func eachWith<T>(_ other: Result<T, Failure>) -> Result<[(Success.Element, T)], Failure> {
        switch (self, other) {
            case (.success(let a), .success(let b)):
                return .success(a.map { ($0, b) })
            case (.failure(let a), _):
                return .failure(a)
            case (_, .failure(let b)):
                return .failure(b)
        }
    }
    
    public func flatMap<NewElement>(_ perform: (Success.Element) -> NewElement) -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                let mapped = items.map(perform)
                return .success(mapped)
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func compactFlatMap<NewElement>(_ perform: (Success.Element) -> NewElement?) -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                let mapped = items.compactMap(perform)
                return .success(mapped)
            case .failure(let err):
                return .failure(err)
        }
    }
    
}

extension Result where Success: Collection {
    
    public func flatMapResults<NewElement>(_ perform: (Success.Element) -> Result<NewElement, Failure>) -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                var collected = Array<NewElement>()
                for item in items {
                    switch perform(item) {
                        case .success(let element): collected.append(element)
                        case .failure(let err): return .failure(err)
                    }
                }
                return .success(collected)
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func flatMapResults<NewElement>(_ perform: (Success.Element) async -> Result<NewElement, Failure>) async -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                var collected = Array<NewElement>()
                for item in items {
                    switch await perform(item) {
                        case .success(let element): collected.append(element)
                        case .failure(let err): return .failure(err)
                    }
                }
                return .success(collected)
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func compactFlatMapResults<NewElement>(_ perform: (Success.Element) -> Result<NewElement?, Failure>) -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                var collected = Array<NewElement>()
                for item in items {
                    switch perform(item) {
                        case .success(let element):
                            if let unwrapped = element { collected.append(unwrapped) }
                        case .failure(let err):
                            return .failure(err)
                    }
                }
                return .success(collected)
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func flatMapResults<NewElement>(_ perform: (Success.Element) async -> Result<NewElement?, Failure>) async -> Result<[NewElement], Failure> {
        switch self {
            case .success(let items):
                var collected = Array<NewElement>()
                for item in items {
                    switch await perform(item) {
                        case .success(let element):
                            if let unwrapped = element { collected.append(unwrapped) }
                        case .failure(let err):
                            return .failure(err)
                    }
                }
                return .success(collected)
            case .failure(let err):
                return .failure(err)
        }
    }
    
}
