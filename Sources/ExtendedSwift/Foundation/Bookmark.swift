//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/4/23.
//

import Foundation

public struct Bookmark: Codable {
    
    public enum BookmarkError: Error {
        case staleBookmark
        case cannotResolve(Error)
        case cannotSecurelyAccess
    }
    
    public final class AccessToken: Sendable {
        fileprivate let url: URL
        private let isAccessingSecurityScopedResource: Bool
        
        fileprivate init(url: URL, isAccessing: Bool) {
            self.url = url
            self.isAccessingSecurityScopedResource = isAccessing
        }
        
        deinit {
            if isAccessingSecurityScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    private let data: Data
    
    public init(referencing url: URL, options: URL.BookmarkCreationOptions = []) throws {
        self.data = try url.bookmarkData(options: options)
    }
    
    public init(referencing path: Path, options: URL.BookmarkCreationOptions = []) throws {
        try self.init(referencing: path.fileURL, options: options)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.data = try container.decode(Data.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.data)
    }
    
    private func _access(options: URL.BookmarkResolutionOptions) -> Result<AccessToken, BookmarkError> {
        let result: Result<AccessToken, BookmarkError>
        do {
            var isStale = false
            let u = try URL(resolvingBookmarkData: data,
                            options: options,
                            relativeTo: nil,
                            bookmarkDataIsStale: &isStale)
            
            if isStale {
                result = .failure(.staleBookmark)
            } else {
                if options.contains(.withSecurityScope) {
                    if u.startAccessingSecurityScopedResource() {
                        result = .success(AccessToken(url: u, isAccessing: true))
                    } else {
                        result = .failure(.cannotSecurelyAccess)
                    }
                } else {
                    result = .success(AccessToken(url: u, isAccessing: false))
                }
            }
        } catch {
            result = .failure(.cannotResolve(error))
        }
        return result
    }
    
    public func accessResource(options: URL.BookmarkResolutionOptions = [.withSecurityScope]) throws -> AccessToken {
        return try _access(options: options).get()
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = [.withSecurityScope],
                                   perform work: (Result<URL, BookmarkError>) async throws -> T) async rethrows -> T {
        
        let result = _access(options: options)
        switch result {
            case .success(let token):
                return try await withExtendedLifetime(token) {
                    return try await work(.success($0.url))
                }
            case .failure(let error):
                return try await work(.failure(error))
        }
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = [.withSecurityScope], 
                                   perform work: (Result<URL, BookmarkError>) throws -> T) rethrows -> T {
        
        let result = _access(options: options)
        switch result {
            case .success(let token):
                return try withExtendedLifetime(token) {
                    return try work(.success($0.url))
                }
            case .failure(let error):
                return try work(.failure(error))
        }
    }
    
}
