//
//  NSMenu.swift
//  ExtendedKit
//
//  Created by Dave DeLong on 3/8/23.
//

import Foundation

#if os(macOS)

import Cocoa

extension NSMenu {
    
    @discardableResult
    func addItem(withTitle title: String, target: AnyObject, action: Selector, representedObject: Any? = nil) -> NSMenuItem {
        let i = self.addItem(withTitle: title, action: action, keyEquivalent: "")
        i.target = target
        i.representedObject = representedObject
        return i
    }
    
    @discardableResult
    func addItem(withTitle title: String, handler: @escaping (Any) -> Void) -> NSMenuItem {
        let i = self.addItem(withTitle: title, action: nil, keyEquivalent: "")
        i.setActionHandler(handler)
        return i
    }
    
}

#endif
