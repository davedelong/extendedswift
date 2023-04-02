//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public struct PostOrderTraversal<T: Tree>: TreeTraversing {
    public typealias Tree = T
    
    public enum Disposition: TreeTraversingDisposition {
        public static var keepGoing: Disposition { return .continue }
        
        case halt
        case `continue`
        
        public var halts: Bool { return self == .halt }
    }
    
    public init() { }
    
    public func traverse(tree: Tree, level: Int, visitor: (Tree, Int) throws -> Disposition) rethrows -> Disposition {
        for child in tree.children {
            let nodeD = try traverse(tree: child, level: level+1, visitor: visitor)
            if nodeD.halts { return nodeD }
        }
        
        return try visitor(tree, level)
    }
}
