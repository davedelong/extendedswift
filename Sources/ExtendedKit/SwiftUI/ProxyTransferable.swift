//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/18/23.
//

import SwiftUI

public protocol ProxyTransferable: Transferable where Representation == ProxyRepresentation<Self, Proxy> {
    associatedtype Proxy: Transferable
    
    // Implement one of these:
    func transferableProxy() throws -> Proxy
    func transferableProxy() async throws -> Proxy
}

extension ProxyTransferable {
    
    public func transferableProxy() throws -> Proxy {
        throw UnimplementedError()
    }
    
    public func transferableProxy() async throws -> Proxy {
        // Needed because `try self.transferableProxy()` thinks its refering to the async version
        let method: () throws -> Proxy = self.transferableProxy
        return try method()
    }
    
    public static var transferRepresentation: ProxyRepresentation<Self, Proxy> {
        ProxyRepresentation(exporting: { simple in
            return try await simple.transferableProxy()
        })
    }
    
}
