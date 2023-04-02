//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public protocol TreeTraversingDisposition {
    static var keepGoing: Self { get }
    var halts: Bool { get }
}

public protocol TreeTraversing {
    associatedtype Disposition: TreeTraversingDisposition
    associatedtype Tree: ExtendedSwift.Tree
    
    func traverse(tree: Tree, level: Int, visitor: (Tree, Int) throws -> Disposition) rethrows -> Disposition
}

extension TreeTraversing {
    
    internal func traverse(tree: Tree, visitor: (Tree) throws -> Disposition) rethrows -> Disposition {
        return try self.traverse(tree: tree, level: 0, visitor: { node, _ in
            return try visitor(node)
        })
    }
    
    internal func traverse(tree: Tree, visitor: (Tree, Int) throws -> Disposition) rethrows -> Disposition {
        return try self.traverse(tree: tree, level: 0, visitor: visitor)
    }
    
}

extension Tree {
    
    @discardableResult
    public func traverse<T: TreeTraversing>(in order: T, visitor: (Self) throws -> T.Disposition) rethrows -> T.Disposition where T.Tree == Self {
        return try order.traverse(tree: self, visitor: visitor)
    }
    
    @discardableResult
    public func traverse<T: TreeTraversing>(in order: T, visitor: (Self, Int) throws -> T.Disposition) rethrows -> T.Disposition where T.Tree == Self {
        return try order.traverse(tree: self, visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (Self) throws -> PreOrderTraversal<Self>.Disposition) rethrows -> PreOrderTraversal<Self>.Disposition {
        return try traverse(in: PreOrderTraversal(), visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (Self, Int) throws -> PreOrderTraversal<Self>.Disposition) rethrows -> PreOrderTraversal<Self>.Disposition {
        return try traverse(in: PreOrderTraversal(), visitor: visitor)
    }
    
    public func flatten<T: TreeTraversing>(in order: T) -> Array<T.Tree> where T.Tree == Self {
        var flattened = Array<T.Tree>()
        
        traverse(in: order) {
            flattened.append($0)
            return T.Disposition.keepGoing
        }
        
        return flattened
    }
    
    public var flattened: Array<Self> {
        return flatten(in: PreOrderTraversal())
    }
    
    public var preOrder: Array<Self> { flatten(in: PreOrderTraversal()) }
    
    public var postOrder: Array<Self> { flatten(in: PostOrderTraversal()) }
    
    public var breadthFirstOrder: Array<Self> { flatten(in: BreadthFirstTreeTraversal()) }
    
    public func treeDescription(using describer: (Self) -> String) -> String {
        var lines = Array<String>()
        self.traverse(in: PreOrderTraversal(), visitor: { node, level in
            let symbol = node.isLeaf ? "-" : "+"
            lines.append(String(repeating: "  ", count: level) + symbol + " " + describer(node))
            return .continue
        })
        return lines.joined(separator: "\n")
    }
    
}

extension Tree where Self: CustomStringConvertible {
    
    public var treeDescription: String { self.treeDescription(using: \.description) }
    
}

extension Collection where Element: Tree {
    
    public func traverseElements<T: TreeTraversing>(in order: T, visitor: (Element) throws -> T.Disposition) rethrows where T.Tree == Element {
        for item in self {
            let d = try item.traverse(in: order, visitor: visitor)
            if d.halts { return }
        }
    }
    
    public func traverseElements(visitor: (Element) throws -> PreOrderTraversal<Element>.Disposition) rethrows {
        try traverseElements(in: PreOrderTraversal(), visitor: visitor)
    }
    
    public func flatten<T: TreeTraversing>(in order: T) -> Array<T.Tree> where T.Tree == Element {
        var flattened = Array<T.Tree>()
        for node in self {
            node.traverse(in: order) {
                flattened.append($0)
                return T.Disposition.keepGoing
            }
        }
        return flattened
    }
    
    public func flatten() -> Array<Element> {
        return flatten(in: PreOrderTraversal())
    }
    
}
