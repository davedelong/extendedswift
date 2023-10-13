//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation
import Logging

// In-order traversal only works on binary tree nodes, because general tree nodes don't have a notion of "left" or "right" children
public struct InOrderTraversal: TreeTraversal {
    
    public enum Action: TreeTraversalAction {
        public static var keepGoing: Action { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    @discardableResult
    public func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        return try traverse(tree: tree, context: .init(), visitor: visitor)
    }
    
    private func traverse<Value>(tree: any Tree<Value>, context: Context, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        
        guard let btree = tree as? any BinaryTree<Value> else {
            Logger.runtimeWarning("InOrderTraversal can only be used with BinaryTrees")
            return .halt
        }
        
        if let l = btree.left {
            let d = try traverse(tree: l, context: context.increment(), visitor: visitor)
            if d.halts { return d }
        }
        
        let d = try visitor(tree, context)
        if d.halts { return d }
        
        if let r = btree.right, d != .skipChildren {
            let d = try traverse(tree: r, context: context.increment(), visitor: visitor)
            if d.halts { return d }
        }
        
        return .continue
    }
}
