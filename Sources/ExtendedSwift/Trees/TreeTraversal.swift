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
    
    func traverse<Value>(tree: any Tree<Value>, level: Int, visitor: (any Tree<Value>, Int) throws -> Disposition) rethrows -> Disposition
}

extension TreeTraversing {
    
    internal func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>) throws -> Disposition) rethrows -> Disposition {
        return try self.traverse(tree: tree, level: 0, visitor: { node, _ in
            return try visitor(node)
        })
    }
    
    internal func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Int) throws -> Disposition) rethrows -> Disposition {
        return try self.traverse(tree: tree, level: 0, visitor: visitor)
    }
    
}

extension Tree {
    
    @discardableResult
    public func traverse<T: TreeTraversing>(in order: T, visitor: (any Tree<Value>) throws -> T.Disposition) rethrows -> T.Disposition {
        return try order.traverse(tree: self, visitor: visitor)
    }
    
    @discardableResult
    public func traverse<T: TreeTraversing>(in order: T, visitor: (any Tree<Value>, Int) throws -> T.Disposition) rethrows -> T.Disposition {
        return try order.traverse(tree: self, visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (any Tree<Value>) throws -> PreOrderTraversal.Disposition) rethrows -> PreOrderTraversal.Disposition {
        return try traverse(in: PreOrderTraversal(), visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (any Tree<Value>, Int) throws -> PreOrderTraversal.Disposition) rethrows -> PreOrderTraversal.Disposition {
        return try traverse(in: PreOrderTraversal(), visitor: visitor)
    }
    
    public func flatten<T: TreeTraversing, Output>(in order: T, using output: (any Tree<Value>) -> Output) -> Array<Output> {
        var flattened = Array<Output>()
        
        traverse(in: order) {
            flattened.append(output($0))
            return T.Disposition.keepGoing
        }
        
        return flattened
    }
    
    public func flattenValues<T: TreeTraversing>(in order: T) -> Array<Value> {
        var flattened = Array<Value>()
        
        traverse(in: order) {
            flattened.append($0.value)
            return T.Disposition.keepGoing
        }
        
        return flattened
    }
    
    public var flattenedValues: Array<Value> {
        return flattenValues(in: PreOrderTraversal())
    }
    
    public var preOrderValues: Array<Value> { flattenValues(in: PreOrderTraversal()) }
    
    public var postOrderValues: Array<Value> { flattenValues(in: PostOrderTraversal()) }
    
    public var breadthFirstOrderValues: Array<Value> { flattenValues(in: BreadthFirstTreeTraversal()) }
    
    public func treeDescription(using describer: (any Tree<Value>) -> String) -> String {
        var lines = Array<String>()
        self.traverse(in: PreOrderTraversal(), visitor: { node, level in
            let symbol = node.isLeaf ? "-" : "+"
            lines.append(String(repeating: "  ", count: level) + symbol + " " + describer(node))
            return .continue
        })
        return lines.joined(separator: "\n")
    }
    
}

extension Tree where Value: CustomStringConvertible {
    
    public var treeDescription: String { self.treeDescription(using: { $0.value.description }) }
    
}

extension Collection where Element: Tree {
    
    public func traverseElements<T: TreeTraversing>(in order: T, visitor: (any Tree<Element.Value>) throws -> T.Disposition) rethrows {
        for item in self {
            let d = try item.traverse(in: order, visitor: visitor)
            if d.halts { return }
        }
    }
    
    public func traverseElements(visitor: (any Tree<Element.Value>) throws -> PreOrderTraversal.Disposition) rethrows {
        try traverseElements(in: PreOrderTraversal(), visitor: visitor)
    }
    
    public func flattenValues<T: TreeTraversing>(in order: T) -> Array<Element.Value> {
        var flattened = Array<Element.Value>()
        for node in self {
            node.traverse(in: order) {
                flattened.append($0.value)
                return T.Disposition.keepGoing
            }
        }
        return flattened
    }
    
    public func flattenValues() -> Array<Element.Value> {
        return flattenValues(in: PreOrderTraversal())
    }
    
}
