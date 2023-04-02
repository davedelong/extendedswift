//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public struct BreadthFirstTreeTraversal<T: Tree>: TreeTraversing {
    public typealias Tree = T
    
    public enum Disposition: TreeTraversingDisposition {
        public static var keepGoing: Disposition { return .continue }
        
        case halt
        case `continue`
        case skipChildren
        
        public var halts: Bool { return self == .halt }
    }
    
    public func traverse(tree: T, level: Int, visitor: (T, Int) throws -> Disposition) rethrows -> Disposition {
        var nodesToVisit = ArraySlice([(tree, level)])
        
        while let (nextNode, nodeLevel) = nodesToVisit.popFirst() {
            let nodeDisposition = try visitor(nextNode, nodeLevel)
            switch nodeDisposition {
                case .halt: return .halt
                case .continue: nodesToVisit.append(contentsOf: nextNode.children.map { ($0, nodeLevel + 1) })
                case .skipChildren: continue
            }
        }
        
        return .continue
        
    }
    
}
