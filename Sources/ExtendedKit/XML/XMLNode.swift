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
    
    public subscript(attribute: String) -> XMLNode? {
        get {
            return self.attribute(forName: attribute)
        }
        set {
            if let newValue {
                if let existing = self.attribute(forName: attribute), existing != newValue {
                    self.removeAttribute(forName: attribute)
                    self.addAttribute(newValue)
                }
            } else {
                self.removeAttribute(forName: attribute)
            }
        }
    }
    
    public subscript(string attribute: String) -> String? {
        get {
            return self[attribute]?.stringValue
        }
        set {
            if let newValue {
                if let existing = self[attribute] {
                    existing.stringValue = newValue
                } else {
                    self.addAttribute(attribute, value: newValue)
                }
            } else {
                self.removeAttribute(forName: attribute)
            }
        }
    }
    
    public subscript(url attribute: String, relativeTo base: URL? = nil) -> URL? {
        get {
            guard let string = self[string: attribute] else { return nil }
            return URL(string: string, relativeTo: base)?.absoluteURL
        }
        set {
            if let newValue {
                if let existing = self[attribute] {
                    existing.stringValue = newValue.absoluteString
                } else {
                    self.addAttribute(attribute, value: newValue.absoluteString)
                }
            } else {
                self.removeAttribute(forName: attribute)
            }
        }
    }
    
    public func string(forAttribute attribute: String) -> String? {
        return self[string: attribute]
    }
    
    public func url(forAttribute attribute: String, relativeTo base: URL?) -> URL? {
        return self[url: attribute, relativeTo: base]
    }
    
    @discardableResult
    public func addAttribute(_ name: String, value: String) -> XMLNode {
        let attr = XMLNode.attribute(withName: name, stringValue: value) as! XMLNode
        self.addAttribute(attr)
        return attr
    }
    
}


#endif
