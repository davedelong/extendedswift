//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import Logging
import CoreData

internal let LogSchema: NSManagedObjectModel = {
    
    let m = NSManagedObjectModel()
    
    let entryEntity = NSEntityDescription()
    entryEntity.name = "LogEntry"
    entryEntity.properties = [
        NSAttributeDescription(name: "timestamp", optional: false, type: .dateAttributeType),
        NSAttributeDescription(name: "level", optional: false, type: .stringAttributeType),
        NSAttributeDescription(name: "category", optional: false, type: .stringAttributeType),
        NSAttributeDescription(name: "message", optional: false, type: .stringAttributeType),
        NSAttributeDescription(name: "source", optional: false, type: .stringAttributeType),
        NSAttributeDescription(name: "location", optional: false, type: .stringAttributeType),
        NSAttributeDescription(name: "metadata", optional: true, type: .stringAttributeType),
    ]
    
    m.entities = [entryEntity]
    
    return m
}()

internal let LogFileExtension = "logstore"

public struct CoreDataLogHandler: LogHandler {
    private let store: CoreDataLogStore
    
    private let category: String
    
    public init(label: String, sandbox: Sandbox) {
        self.category = label
        self.store = sandbox.currentLogStore
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
    
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .trace
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let entry = LogEntry(timestamp: Date(),
                             category: category,
                             level: level,
                             message: message,
                             location: "\(file):\(line) \(function)",
                             source: source,
                             metadata: metadata)
        
        store.log(entry)
    }
}

public class CoreDataLogStore {
    private static let timestampFormatter = POSIXDateFormatter(dateFormat: "y-MM-dd'T'HH-mm-ssXX")
    
    private var psc: NSPersistentStoreCoordinator?
    public var file: Path?
    
    private let metadataEncoder = JSONEncoder()

    public private(set) var readContext: NSManagedObjectContext
    private var writeContext: NSManagedObjectContext?
    
    public var isCurrent: Bool { writeContext != nil }
    public var isDeleted: Bool { psc == nil }
    
    public let timestamp: Date
    public let name: String
    
    private init(storeFile: Path) throws {
        let basename = try storeFile.lastComponent?.itemBaseName ?! CocoaError(.fileReadInvalidFileName)
        let timestamp = try Self.timestampFormatter.date(from: basename) ?! CocoaError(.fileReadInvalidFileName)
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: LogSchema)
        self.psc = psc
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        self.writeContext = moc
        
        self.timestamp = timestamp
        self.name = basename
        self.file = storeFile
        self.readContext = ReadOnlyManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.readContext.persistentStoreCoordinator = self.psc
        
        try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeFile.fileURL, options: [
            NSSQLitePragmasOption: [
                "journal_mode": "OFF"
            ]
        ])
    }
    
    fileprivate convenience init?(file: Path) {
        do {
            try self.init(storeFile: file)
        } catch {
            print("Could not open log store at", file.fileSystemPath)
            return nil
        }
        
        // make sure it's read-only
        self.writeContext = nil
    }
    
    fileprivate convenience init(sandbox: Sandbox) {
        let logsFolder = sandbox.logsPath
        
        let now = Date()
        let formattedTime = Self.timestampFormatter.string(from: now)
        let storeName = "\(formattedTime).\(LogFileExtension)"
        let storeFile = logsFolder.appending(component: storeName)
        
        try! self.init(storeFile: storeFile)
        
        self.readContext = ReadOnlyManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.readContext.persistentStoreCoordinator = self.psc
    }
    
    internal func log(_ e: LogEntry) {
        guard let moc = writeContext else {
            return
        }
        
        moc.perform {
            let entry = NSManagedObject(entity: LogEntry.entity, insertInto: moc)
            entry.setValue(e.timestamp, forKey: "timestamp")
            entry.setValue(e.level.rawValue, forKey: "level")
            entry.setValue(e.category, forKey: "category")
            entry.setValue(e.message.description, forKey: "message")
            entry.setValue(e.source, forKey: "source")
            entry.setValue(e.location, forKey: "location")
            
            if let md = e.metadata,
               let data = try? self.metadataEncoder.encode(md),
               let json = String(data: data, encoding: .utf8) {
                
                entry.setValue(json, forKey: "metadata")
            }
            
            try? moc.save()
        }
    }
    
    public func delete() throws {
        guard isCurrent == false else {
            throw CocoaError(.persistentStoreOpen)
        }
        
        guard let url = file?.fileURL else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        guard let coordinator = psc else {
            throw CocoaError(.persistentStoreOperation)
        }
        
        try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: [:])
        try FileManager.default.removeItem(at: url)
        
        readContext = ReadOnlyManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        writeContext = nil
        psc = nil
        file = nil
    }
}

enum CoreDataLogStoreProperty: SandboxProperty {
    typealias PropertyValue = CoreDataLogStore
    
    static func provideValue(for sandbox: ExtendedSwift.Sandbox) -> CoreDataLogStore {
        return CoreDataLogStore(sandbox: sandbox)
    }
}

extension Sandbox {
    
    public var currentLogStore: CoreDataLogStore {
        self[CoreDataLogStoreProperty.self]
    }
    
    public var logStoreContext: NSManagedObjectContext {
        self.currentLogStore.readContext
    }
    
    public var previousLogStores: Array<CoreDataLogStore> {
        let others = FileManager.default.contentsOfDirectory(at: self.logsPath,
                                                             includingPropertiesForKeys: nil,
                                                             options: [.skipsSubdirectoryDescendants])
        
        let stores = others.filter { $0.extension == LogFileExtension }
        var sorted = stores.sorted(by: \.lastItem.unwrapped)
        
        if let existing = self.existingValue(for: CoreDataLogStoreProperty.self) {
            sorted.removeAll(where: { $0 == existing.file })
        }
        
        return sorted.compactMap { CoreDataLogStore(file: $0) }
    }
    
}
