//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    
    public static var devNull: URL { URL(fileURLWithPath: "/dev/null") }
    
    public init(_ raw: StaticString) {
        self.init(string: raw.description)!
    }
    
    public var parent: URL? { return self.deletingLastPathComponent() }
    
    public var contentType: UTType? {
        let values = try? self.resourceValues(forKeys: [.contentTypeKey])
        return values?.contentType
    }
    
    public func relationship(to other: URL) -> FileManager.URLRelationship {
        var relationship: FileManager.URLRelationship = .other
        _ = try? FileManager.default.getRelationship(&relationship, ofDirectoryAt: self, toItemAt: other)
        return relationship
    }
    
    public func contains(_ other: URL) -> Bool {
        let r = relationship(to: other)
        return (r == .contains || r == .same)
    }
    
    public func value(forQueryItem item: String) -> String? {
        guard let c = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return c.queryItems?.first(where: { $0.name == item })?.value
    }
    
    public func deletingQueryItem(_ name: String) -> URL {
        guard var c = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        c.queryItems = c.queryItems?.filter { $0.name != name }
        return c.url ?? self
    }
    
}

extension URL {
    
    public var isIncludedInBackup: Bool {
        get {
            let values = try? resourceValues(forKeys: [.isExcludedFromBackupKey])
            return (values?.isExcludedFromBackup == false)
        }
        nonmutating set {
            var copy = self
            var newValues = URLResourceValues()
            newValues.isExcludedFromBackup = (newValue == false)
            try? copy.setResourceValues(newValues)
        }
    }
}
