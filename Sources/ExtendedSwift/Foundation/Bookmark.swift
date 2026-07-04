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
    
    public init(data: Data) {
        self.data = data
    }
    
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
    
    internal func access(options: URL.BookmarkResolutionOptions) throws(BookmarkError) -> AccessToken {
        do {
            var isStale = false
            let u = try URL(resolvingBookmarkData: data,
                            options: options,
                            relativeTo: nil,
                            bookmarkDataIsStale: &isStale)
            
            if isStale {
                throw BookmarkError.staleBookmark
            } else {
                let shouldStartAccessing: Bool
#if os(macOS)
                shouldStartAccessing = options.contains(.withSecurityScope) && options.contains(.withoutImplicitStartAccessing) == false
#else
                shouldStartAccessing = options.contains(.withoutImplicitStartAccessing) == false
#endif
                
                if shouldStartAccessing {
                    if u.startAccessingSecurityScopedResource() {
                        return AccessToken(url: u, isAccessing: true)
                    } else {
                        throw BookmarkError.cannotAccessSecurityScopedResource
                    }
                } else {
                    return AccessToken(url: u, isAccessing: false)
                }
            }
        } catch let error as BookmarkError {
            throw error
        } catch {
            throw .cannotResolve(error)
        }
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
    
    private static var defaultResolutionOptions: URL.BookmarkResolutionOptions {
        #if os(macOS)
        return [.withSecurityScope]
        #else
        return []
        #endif
    }
    
    public func accessResource(options: URL.BookmarkResolutionOptions? = nil) throws(BookmarkError) -> AccessToken {
        let resolvedOptions = options ?? Self.defaultResolutionOptions
        return try access(options: resolvedOptions)
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions? = nil,
                                   perform work: (URL) async throws -> T) async throws -> T {
        
        let resolvedOptions = options ?? Self.defaultResolutionOptions
        let token = try access(options: resolvedOptions)
        return try await withExtendedLifetime(token) {
            return try await work($0.url)
        }
    }
    
    @discardableResult
    public func withResolvedURL<T>(options: URL.BookmarkResolutionOptions? = nil,
                                   perform work: (URL) throws -> T) throws -> T {
        
        let resolvedOptions = options ?? Self.defaultResolutionOptions
        let token = try access(options: resolvedOptions)
        return try withExtendedLifetime(token) {
            return try work($0.url)
        }
    }
    
    @discardableResult
    public func withResolvedPath<T>(options: URL.BookmarkResolutionOptions? = nil,
                                    perform work: (Path) async throws -> T) async throws -> T {
        
        let resolvedOptions = options ?? Self.defaultResolutionOptions
        return try await self.withResolvedURL(options: resolvedOptions, perform: { url in
            return try await work(Path(url))
        })
        
    }
    
    @discardableResult
    public func withResolvedPath<T>(options: URL.BookmarkResolutionOptions? = nil,
                                    perform work: (Path) throws -> T) throws -> T {
        
        return try self.withResolvedURL(options: options, perform: { url in
            return try work(Path(url))
        })
        
    }
    
}
