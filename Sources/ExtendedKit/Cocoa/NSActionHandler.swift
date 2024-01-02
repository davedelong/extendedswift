//
//  NSActionHandler.swift
//  ExtendedKit
//
//  Created by Dave DeLong on 12/31/23.
//

import Foundation

#if os(macOS)

import AppKit

extension NSControl {
    
    public func setActionHandler(_ handler: @escaping (Any) -> Void) {
        let target = ActionHandler(handler: handler)
        self.target = target
        self.action = #selector(ActionHandler.perform(_:))
        objc_setAssociatedObject(self, &actionKey, handler, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
}

extension NSMenuItem {
    
    public func setActionHandler(_ handler: @escaping (Any) -> Void) {
        let target = ActionHandler(handler: handler)
        self.target = target
        self.action = #selector(ActionHandler.perform(_:))
        objc_setAssociatedObject(self, &actionKey, handler, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

#endif

private var actionKey: UInt8 = 0

@objc
private class ActionHandler: NSObject {
    
    let handler: (Any) -> Void
    
    init(handler: @escaping (Any) -> Void) {
        self.handler = handler
    }
    
    @objc
    func perform(_ sender: Any) {
        handler(sender)
    }
}
