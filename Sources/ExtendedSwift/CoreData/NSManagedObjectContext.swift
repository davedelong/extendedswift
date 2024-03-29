//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import CoreData

public class ReadOnlyManagedObjectContext: NSManagedObjectContext {
    
    override public func save() throws {
        throw CocoaError(.persistentStoreSave, userInfo: [
            NSLocalizedDescriptionKey: "This context is read-only"
        ])
    }
    
}

extension NSManagedObjectContext {
    
    public func fullObject<T: NSManagedObject>(with id: NSManagedObjectID) -> T? {
        let e = try? self.existingObject(with: id)
        guard let typed = e as? T else { return nil }
        self.refresh(typed, mergeChanges: true)
        return typed
    }
    
    public func fetch<E: NSManagedObject>(_ type: E.Type = E.self, ids: Array<String>) throws -> Array<E> {
        let fr = NSFetchRequest<E>()
        fr.entity = E.entity()
        fr.predicate = NSPredicate(format: "id IN %@", ids)
        fr.sortDescriptors = []
        return try self.fetch(fr)
    }
    
    @discardableResult
    public func perform<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    let result = try work(self)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @discardableResult
    public func perform<T>(_ work: @escaping (NSManagedObjectContext) -> T) async -> T {
        return await withCheckedContinuation { continuation in
            self.perform {
                let result = work(self)
                continuation.resume(returning: result)
            }
        }
    }
    
    public struct SaveResult {
        
        public let insertedObjects: Set<NSManagedObject>
        public let updatedObjects: Set<NSManagedObject>
        public let deletedObjects: Set<NSManagedObject>
        public let refreshedObjects: Set<NSManagedObject>
        public let invalidatedObjects: Set<NSManagedObject>
        
        public let invalidatedAllObjects: Bool
        
        internal init?(_ note: Notification) {
            guard note.name == NSManagedObjectContext.didSaveObjectsNotification else { return nil }
            guard let info = note.userInfo else { return nil }
            
            self.insertedObjects = info[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
            self.updatedObjects = info[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
            self.deletedObjects = info[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
            self.refreshedObjects = info[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? []
            self.invalidatedObjects = info[NSInvalidatedObjectsKey] as? Set<NSManagedObject> ?? []
            self.invalidatedAllObjects = info[NSInvalidatedAllObjectsKey] as? Bool ?? false
        }
        
    }
    
    public func performSave() -> Result<SaveResult, Error> {
        var saveResult: SaveResult?
        let token = NotificationCenter.default.addObserver(forName: NSManagedObjectContext.didSaveObjectsNotification, 
                                                           object: self,
                                                           queue: nil,
                                                           using: { saveResult = SaveResult($0) })
        
        let result: Result<SaveResult, Error>
        do {
            try self.save()
            if let saveResult {
                result = .success(saveResult)
            } else {
                result = .failure(CocoaError(.persistentStoreIncompleteSave))
            }
        } catch {
            result = .failure(error)
        }
        
        NotificationCenter.default.removeObserver(token)
        return result
    }
    
}
