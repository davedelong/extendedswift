//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/30/23.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    
    @discardableResult
    public func withBackgroundContext<T>(perform work: @escaping (NSManagedObjectContext) -> T) async -> T {
        let moc = self.newBackgroundContext()
        return await moc.perform(work)
    }
    
    @discardableResult
    public func withBackgroundContext<T>(perform work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let moc = self.newBackgroundContext()
        return try await moc.perform(work)
    }
    
}
