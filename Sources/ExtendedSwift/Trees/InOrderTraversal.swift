//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

// In-order traversal only works on binary tree nodes, because general tree nodes don't have a notion of "left" or "right" children
public struct InOrderTraversal: TreeTraversing {
    
    public enum Disposition: TreeTraversingDisposition {
        public static var keepGoing: Disposition { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    public func traverse<Value>(tree: any Tree<Value>, level: Int, visitor: (any Tree<Value>, Int) throws -> Disposition) rethrows -> Disposition {
        
        guard let btree = tree as? any BinaryTree<Value> else {
            return .halt
        }
        
        if let l = btree.left {
            let d = try traverse(tree: l, level: level+1, visitor: visitor)
            if d.halts { return d }
        }
        
        let d = try visitor(tree, level)
        if d.halts { return d }
        
        if let r = btree.right, d != .skipChildren {
            let d = try traverse(tree: r, level: level+1, visitor: visitor)
            if d.halts { return d }
        }
        
        return .continue
    }
}
