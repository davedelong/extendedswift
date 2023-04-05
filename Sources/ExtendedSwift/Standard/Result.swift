//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Result {
    
    public var success: Success? {
        if case .success(let s) = self { return s }
        return nil
    }
    
    public var failure: Failure? {
        if case .failure(let failure) = self { return failure }
        return nil
    }
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }
    
    public func eraseSuccess() -> Result<Void, Failure> {
        switch self {
            case .success: return .success(())
            case .failure(let e): return .failure(e)
        }
    }
    
}

extension Result where Success == Void {
    
    public static var success: Self { return Result<Void, Failure>.success(()) }
    
}

extension Result where Failure == Error {
    
    public init(attempting: () async throws -> Success) async {
        do {
            let value = try await attempting()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
    
}
