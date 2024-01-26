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
        case cannotAccessSecurityScopedResource
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
    
    public let data: Data
    
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
    
    internal func access(options: URL.BookmarkResolutionOptions) -> Result<AccessToken, BookmarkError> {
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
                let shouldStartAccessing: Bool
                #if os(macOS)
                shouldStartAccessing = options.contains(.withSecurityScope) && options.contains(.withoutImplicitStartAccessing) == false
                #else
                shouldStartAccessing = options.contains(.withoutImplicitStartAccessing) == false
                #endif
                
                if shouldStartAccessing {
                    if u.startAccessingSecurityScopedResource() {
                        result = .success(AccessToken(url: u, isAccessing: true))
                    } else {
                        result = .failure(.cannotAccessSecurityScopedResource)
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
    
}

extension Bookmark.AccessToken {
    
    @discardableResult
    public func withURL<T>(perform work: (Result<URL, Bookmark.BookmarkError>) throws -> T) rethrows -> T {
        var r = Result<URL, Bookmark.BookmarkError>.success(url)
        var needsStopping = false
        if isAccessingSecurityScopedResource == false {
            if url.startAccessingSecurityScopedResource() == false {
                r = .failure(.cannotAccessSecurityScopedResource)
            } else {
                needsStopping = true
            }
        }
        
        defer { if needsStopping { url.stopAccessingSecurityScopedResource() } }
        return try work(r)
    }
    
    @discardableResult
    public func withURL<T>(perform work: (Result<URL, Bookmark.BookmarkError>) async throws -> T) async rethrows -> T {
        var r = Result<URL, Bookmark.BookmarkError>.success(url)
        var needsStopping = false
        if isAccessingSecurityScopedResource == false {
            if url.startAccessingSecurityScopedResource() == false {
                r = .failure(.cannotAccessSecurityScopedResource)
            } else {
                needsStopping = true
            }
        }
        
        defer { if needsStopping { url.stopAccessingSecurityScopedResource() } }
        return try await work(r)
    }
    
    @discardableResult
    public func withPath<T>(perform work: (Result<Path, Bookmark.BookmarkError>) throws -> T) rethrows -> T {
        return try self.withURL { result in
            let mapped = result.map { Path($0) }
            return try work(mapped)
        }
    }
    
    @discardableResult
    public func withPath<T>(perform work: (Result<Path, Bookmark.BookmarkError>) async throws -> T) async rethrows -> T {
        return try await self.withURL { result in
            let mapped = result.map { Path($0) }
            return try await work(mapped)
        }
    }
}

extension Bookmark {
    
    public static var defaultResolutionOptions: URL.BookmarkResolutionOptions {
        #if os(macOS)
        return [.withSecurityScope]
        #else
        return []
        #endif
    }
    
    public func accessResource(options: URL.BookmarkResolutionOptions = Self.defaultResolutionOptions) throws -> AccessToken {
        return try access(options: options).get()
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = Self.defaultResolutionOptions,
                                   perform work: (Result<URL, BookmarkError>) async throws -> T) async rethrows -> T {
        
        let result = access(options: options)
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
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions = Self.defaultResolutionOptions,
                                   perform work: (Result<URL, BookmarkError>) throws -> T) rethrows -> T {
        
        let result = access(options: options)
        switch result {
            case .success(let token):
                return try withExtendedLifetime(token) {
                    return try work(.success($0.url))
                }
            case .failure(let error):
                return try work(.failure(error))
        }
    }
    
    @discardableResult
    public func withResolvedPath<T>(options: URL.BookmarkResolutionOptions = Self.defaultResolutionOptions,
                                    perform work: (Result<Path, BookmarkError>) async throws -> T) async rethrows -> T {
        
        return try await self.withResolvedURL(options: options, perform: { result in
            let mapped = result.map { Path($0) }
            return try await work(mapped)
        })
        
    }
    
    @discardableResult
    public func withResolvedPath<T>(options: URL.BookmarkResolutionOptions = Self.defaultResolutionOptions,
                                    perform work: (Result<Path, BookmarkError>) throws -> T) rethrows -> T {
        
        return try self.withResolvedURL(options: options, perform: { result in
            let mapped = result.map { Path($0) }
            return try work(mapped)
        })
        
    }
    
}
