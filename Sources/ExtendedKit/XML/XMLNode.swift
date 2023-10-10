//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/10/23.
//

#if os(macOS) || canImport(FoundationXML)

import Foundation

#if canImport(FoundationXML)
import FoundationXML
#endif

extension XMLNode {
    
    public func elements(forXPath xpath: String) throws -> Array<XMLElement> {
        let nodes = try self.nodes(forXPath: xpath)
        return nodes.compactMap { $0 as? XMLElement }
    }
    
}

extension XMLElement {
    
    public func string(forAttribute attribute: String) -> String? {
        return self.attribute(forName: attribute)?.stringValue
    }
    
    public func url(forAttribute attribute: String, resolvingAgainst: URL?) -> URL? {
        guard let string = self.string(forAttribute: attribute) else { return nil }
        return URL(string: string, relativeTo: resolvingAgainst)?.absoluteURL
    }
    
}


#endif
