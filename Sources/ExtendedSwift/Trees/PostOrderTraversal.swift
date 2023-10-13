//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public struct PostOrderTraversal: TreeTraversal {
    
    public enum Action: TreeTraversalAction {
        public static var keepGoing: Action { return .continue }
        
        case halt
        case `continue`
        
        public var halts: Bool { return self == .halt }
    }
    
    public init() { }
    
    @discardableResult
    public func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        return try traverse(tree: tree, context: .init(), visitor: visitor)
    }
    
    private func traverse<Value>(tree: any Tree<Value>, context: Context, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        for child in tree.children {
            let nodeD = try traverse(tree: child, context: context.increment(), visitor: visitor)
            if nodeD.halts { return nodeD }
        }
        
        return try visitor(tree, context)
    }
    
}
