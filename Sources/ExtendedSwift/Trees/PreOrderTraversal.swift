//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public struct PreOrderTraversal: TreeTraversal {
    
    public enum Action: TreeTraversalAction {
        public static var keepGoing: Action { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    public init() { }
    
    @discardableResult
    public func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Self.Context) throws -> Action) rethrows -> Action {
        return try traverse(tree: tree, context: .init(), visitor: visitor)
    }
    
    private func traverse<Value>(tree: any Tree<Value>, context: Self.Context, visitor: (any Tree<Value>, Self.Context) throws -> Action) rethrows -> Action {
        let d = try visitor(tree, context)
        if d.halts { return d }
        
        if d != .skipChildren {
            for child in tree.children {
                let nodeD = try traverse(tree: child, context: context.increment(), visitor: visitor)
                if nodeD.halts { return nodeD }
            }
        }
        return .continue
    }
    
}
