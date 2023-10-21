//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation


extension Result {
    
    public func combine<T>(_ other: () -> Result<T, Failure>) -> Result<(Success, T), Failure> {
        switch self {
            case .success(let a):
                switch other() {
                    case .success(let b):
                        return .success((a, b))
                    case .failure(let err):
                        return .failure(err)
                }
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func combine<T>(_ other: () async -> Result<T, Failure>) async -> Result<(Success, T), Failure> {
        switch self {
            case .success(let a):
                switch await other() {
                    case .success(let b):
                        return .success((a, b))
                    case .failure(let err):
                        return .failure(err)
                }
            case .failure(let err):
                return .failure(err)
        }
    }
    
    public func map<NewSuccess>(_ perform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
            case .success(let s):
                let n = perform(s)
                return .success(n)
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func map<NewSuccess>(_ perform: (Success) async -> NewSuccess) async -> Result<NewSuccess, Failure> {
        switch self {
            case .success(let s):
                let n = await perform(s)
                return .success(n)
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess>(_ perform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
            case .success(let s):
                return perform(s)
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess>(_ perform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
            case .success(let s):
                return await perform(s)
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess>(_ perform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
        switch self {
            case .success(let s):
                do {
                    return .success(try perform(s))
                } catch {
                    return .failure(error)
                }
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess, AnyFailure: Error>(_ perform: (Success) -> Result<NewSuccess, AnyFailure>) -> Result<NewSuccess, Error> {
        switch self {
            case .success(let s):
                let result = perform(s)
                switch result {
                    case .success(let new): return .success(new)
                    case .failure(let e): return .failure(e)
                }
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess>(_ perform: (Success) async throws -> NewSuccess) async -> Result<NewSuccess, Error> {
        switch self {
            case .success(let s):
                do {
                    return .success(try await perform(s))
                } catch {
                    return .failure(error)
                }
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func flatMap<NewSuccess, AnyFailure: Error>(_ perform: (Success) async -> Result<NewSuccess, AnyFailure>) async -> Result<NewSuccess, Error> {
        switch self {
            case .success(let s):
                let result = await perform(s)
                switch result {
                    case .success(let new): return .success(new)
                    case .failure(let e): return .failure(e)
                }
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func withFlatMap<NewSuccess>(_ perform: (Success) -> Result<NewSuccess, Failure>) async -> Result<(Success, NewSuccess), Failure> {
        switch self {
            case .success(let s):
                let intermediate = perform(s)
                switch intermediate {
                    case .success(let new):
                        return .success((s, new))
                    case .failure(let e):
                        return .failure(e)
                }
                
            case .failure(let e):
                return .failure(e)
        }
    }
    
    public func withFlatMap<NewSuccess>(_ perform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<(Success, NewSuccess), Failure> {
        switch self {
            case .success(let s):
                let intermediate = await perform(s)
                switch intermediate {
                    case .success(let new):
                        return .success((s, new))
                    case .failure(let e):
                        return .failure(e)
                }
                
            case .failure(let e):
                return .failure(e)
        }
    }
    
}

extension Result {
    
    public func mapFailure<NewFailure>(_ perform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
            case .success(let s):
                return .success(s)
            case .failure(let e):
                let new = perform(e)
                return .failure(new)
        }
    }
    
    public func mapFailure<NewFailure>(_ perform: (Failure) async -> NewFailure) async -> Result<Success, NewFailure> {
        switch self {
            case .success(let s):
                return .success(s)
            case .failure(let e):
                let new = await perform(e)
                return .failure(new)
        }
    }
    
    public func flatMapFailure<NewFailure>(_ perform: (Failure) -> Result<Success, NewFailure>) -> Result<Success, NewFailure> {
        switch self {
            case .success(let s):
                return .success(s)
            case .failure(let e):
                return perform(e)
        }
    }
    
    public func flatMapFailure<NewFailure>(_ perform: (Failure) async -> Result<Success, NewFailure>) async -> Result<Success, NewFailure> {
        switch self {
            case .success(let s):
                return .success(s)
            case .failure(let e):
                return await perform(e)
        }
    }
    
}
