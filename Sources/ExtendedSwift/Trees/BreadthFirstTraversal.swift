//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public struct BreadthFirstTreeTraversal: TreeTraversal {
    
    public enum Action: TreeTraversalAction {
        public static var keepGoing: Action { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    @discardableResult
    public func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        return try self.traverse(tree: tree, context: .init(), visitor: visitor)
    }
    
    private func traverse<Value>(tree: any Tree<Value>, context: Context, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action {
        var nodesToVisit = ArraySlice([(tree, context)])
        
        while let (nextNode, nodeContext) = nodesToVisit.popFirst() {
            let nodeDisposition = try visitor(nextNode, nodeContext)
            switch nodeDisposition {
                case .halt: return .halt
                case .continue: nodesToVisit.append(contentsOf: nextNode.children.map { ($0, nodeContext.increment()) })
                case .skipChildren: continue
            }
        }
        
        return .continue
    }
}
