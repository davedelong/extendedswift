//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension URL {
    
    public init(_ raw: StaticString) {
        self.init(string: raw.description)!
    }
    
    public var parent: URL? { return self.deletingLastPathComponent() }
    
    public func relationship(to other: URL) -> FileManager.URLRelationship {
        var relationship: FileManager.URLRelationship = .other
        _ = try? FileManager.default.getRelationship(&relationship, ofDirectoryAt: self, toItemAt: other)
        return relationship
    }
    
    public func contains(_ other: URL) -> Bool {
        let r = relationship(to: other)
        return (r == .contains || r == .same)
    }
    
}
