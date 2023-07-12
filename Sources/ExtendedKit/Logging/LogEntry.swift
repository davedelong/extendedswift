//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import CoreData
import Logging

public struct LogEntry: Identifiable {
    public var id: Date { timestamp }
    public let timestamp: Date
    public let category: String
    public let level: Logger.Level
    public let message: Logger.Message
    public let location: String
    public let source: String
    public let metadata: Logger.Metadata?
}

extension LogEntry: Fetchable {
    
    internal static var entity: NSEntityDescription { LogSchema.entities[0] }
    
    public struct Filter: FetchFilter {
        public typealias ResultType = NSManagedObject
        public static let all = Filter()
        
        public func fetchRequest() -> NSFetchRequest<ResultType> {
            let r = NSFetchRequest<NSManagedObject>()
            r.entity = LogEntry.entity
            r.predicate = NSPredicate(value: true)
            r.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            return r
        }
        
        public var description: String { "all" }
    }
    
    public init(result: NSManagedObject) {
        self.timestamp = result.value(forKey: "timestamp") as! Date
        self.level = Logger.Level(rawValue: result.value(forKey: "level") as! String)!
        self.category = result.value(forKey: "category") as! String
        self.message = Logger.Message(stringLiteral: result.value(forKey: "message") as! String)
        self.location = result.value(forKey: "location") as? String ?? ""
        self.source = result.value(forKey: "source") as! String
        self.metadata = nil
    }
    
}
