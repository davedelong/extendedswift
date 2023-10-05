//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/4/23.
//

import Foundation

public struct Bookmark: Codable {
    
    public enum SecureAccessError: Error {
        case staleBookmark
        case cannotResolve(Error)
        case cannotSecurelyAccess
    }
    
    public final class SecureAccessToken: Sendable {
        private let url: URL
        
        fileprivate init(url: URL) {
            self.url = url
        }
        
        deinit {
            url.stopAccessingSecurityScopedResource()
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
    
    private func _accessSecurely(options: URL.BookmarkResolutionOptions) -> Result<URL, SecureAccessError> {
        let result: Result<URL, SecureAccessError>
        do {
            var isStale = false
            let u = try URL(resolvingBookmarkData: data,
                            options: options,
                            relativeTo: nil,
                            bookmarkDataIsStale: &isStale)
            
            if isStale {
                result = .failure(.staleBookmark)
            } else if u.startAccessingSecurityScopedResource() {
                result = .success(u)
            } else {
                result = .failure(.cannotSecurelyAccess)
            }
        } catch {
            result = .failure(.cannotResolve(error))
        }
        return result
    }
    
    public func accessSecurely(options: URL.BookmarkResolutionOptions = [.withSecurityScope]) throws -> SecureAccessToken {
        let u = try self._accessSecurely(options: options).get()
        return SecureAccessToken(url: u)
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = [.withSecurityScope],
                                  perform work: (Result<URL, SecureAccessError>) async throws -> T) async rethrows -> T {
        
        let result = self._accessSecurely(options: options)
        switch result {
            case .success(let url):
                defer { url.stopAccessingSecurityScopedResource() }
                return try await work(.success(url))
            case .failure(let error):
                return try await work(.failure(error))
        }
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = [.withSecurityScope], 
                                   perform work: (Result<URL, SecureAccessError>) throws -> T) rethrows -> T {
        
        let result = self._accessSecurely(options: options)
        switch result {
            case .success(let url):
                defer { url.stopAccessingSecurityScopedResource() }
                return try work(.success(url))
            case .failure(let error):
                return try work(.failure(error))
        }
    }
    
}
