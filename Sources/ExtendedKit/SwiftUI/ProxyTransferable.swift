//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/18/23.
//

import SwiftUI

@available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *)
public protocol ProxyTransferable: Transferable where Representation == ProxyRepresentation<Self, Proxy> {
    associatedtype Proxy: Transferable
    
    // Implement one of these:
    func transferableProxy() throws -> Proxy
    func transferableProxy() async throws -> Proxy
}

extension ProxyTransferable {
    
    @available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *)
    public func transferableProxy() throws -> Proxy {
        throw UnimplementedError()
    }
    
    @available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *)
    public func transferableProxy() async throws -> Proxy {
        // Needed because `try self.transferableProxy()` thinks its refering to the async version
        let method: () throws -> Proxy = self.transferableProxy
        return try method()
    }
    
    @available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *)
    public static var transferRepresentation: ProxyRepresentation<Self, Proxy> {
        ProxyRepresentation(exporting: { simple in
            return try await simple.transferableProxy()
        })
    }
    
}
