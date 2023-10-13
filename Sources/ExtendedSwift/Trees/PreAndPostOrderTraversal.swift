//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/12/23.
//

import Foundation

public struct PreAndPostOrderTraversal: TreeTraversal {
    
    public enum Action: TreeTraversalAction {
        public static var keepGoing: Action { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    public enum State {
        case leaf
        case preOrder
        case postOrder
    }
    
    public init() { }
    
    @discardableResult
    public func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        return try traverse(tree: tree,
                            context: .init(level: 0, state: .preOrder),
                            visitor: visitor)
    }
    
    private func traverse<Value>(tree: any Tree<Value>, context: Context, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        
        var c = context
        
        let isLeaf = tree.isLeaf
        
        c.state = isLeaf ? .leaf : .preOrder
        
        let finalDisposition = try visitor(tree, c)
        
        if finalDisposition.halts == false && finalDisposition != .skipChildren {
            for child in tree.children {
                let nodeD = try traverse(tree: child, context: c.increment(), visitor: visitor)
                if nodeD.halts {
                    break
                }
            }
        }
        
        if isLeaf == false {
            c.state = .postOrder
            _ = try visitor(tree, c)
        }
        
        return finalDisposition
    }
    
}
