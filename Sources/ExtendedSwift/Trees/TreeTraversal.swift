//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public protocol TreeTraversalAction {
    static var keepGoing: Self { get }
    var halts: Bool { get }
}

public struct TreeTraversalContext<State> {
    
    public var level: Int
    public var state: State
    
    public init(level: Int, state: State) {
        self.level = level
        self.state = state
    }
    
    public func increment() -> Self {
        return .init(level: level + 1, state: state)
    }
    
}

extension TreeTraversalContext where State == Void {
    
    public init() {
        self.init(level: 0, state: ())
    }
    
}

public protocol TreeTraversal {
    associatedtype Action: TreeTraversalAction
    associatedtype State = Void
    
    typealias Context = TreeTraversalContext<State>
    
    @discardableResult
    func traverse<Value>(tree: any Tree<Value>, visitor: (any Tree<Value>, Context) throws -> Action) rethrows -> Action
}

extension Tree {
    
    @discardableResult
    public func traverse<T: TreeTraversal>(in order: T, visitor: (any Tree<Value>) throws -> T.Action) rethrows -> T.Action {
        return try order.traverse(tree: self, visitor: { tree, _ in
            return try visitor(tree)
        })
    }
    
    @discardableResult
    public func traverse<T: TreeTraversal>(in order: T, visitor: (any Tree<Value>, T.Context) throws -> T.Action) rethrows -> T.Action {
        return try order.traverse(tree: self, visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (any Tree<Value>) throws -> PreOrderTraversal.Action) rethrows -> PreOrderTraversal.Action {
        return try traverse(in: .preOrder, visitor: visitor)
    }
    
    @discardableResult
    public func traverse(visitor: (any Tree<Value>, PreOrderTraversal.Context) throws -> PreOrderTraversal.Action) rethrows -> PreOrderTraversal.Action {
        return try traverse(in: .preOrder, visitor: visitor)
    }
    
    public func flatten<T: TreeTraversal, Output>(in order: T, using output: (any Tree<Value>) -> Output) -> Array<Output> {
        var flattened = Array<Output>()
        
        traverse(in: order) {
            flattened.append(output($0))
            return T.Action.keepGoing
        }
        
        return flattened
    }
    
    public func flattenValues<T: TreeTraversal>(in order: T) -> Array<Value> {
        var flattened = Array<Value>()
        
        traverse(in: order) {
            flattened.append($0.treeValue)
            return T.Action.keepGoing
        }
        
        return flattened
    }
    
    public var flattenedValues: Array<Value> { flattenValues(in: .preOrder) }
    
    public var preOrderValues: Array<Value> { flattenValues(in: .preOrder) }
    
    public var postOrderValues: Array<Value> { flattenValues(in: .postOrder) }
    
    public var breadthFirstOrderValues: Array<Value> { flattenValues(in: .breadthFirst) }
    
    public func treeDescription(using describer: (any Tree<Value>) -> String) -> String {
        var lines = Array<String>()
        self.traverse(in: .preOrder, visitor: { node, ctx in
            let symbol = node.isLeaf ? "-" : "+"
            lines.append(String(repeating: "  ", count: ctx.level) + symbol + " " + describer(node))
            return .continue
        })
        return lines.joined(separator: "\n")
    }
    
}

extension Tree where Value: CustomStringConvertible {
    
    public var treeDescription: String { self.treeDescription(using: { $0.treeValue.description }) }
    
}

extension Collection where Element: Tree {
    
    public func traverseElements<T: TreeTraversal>(in order: T, visitor: (any Tree<Element.Value>) throws -> T.Action) rethrows {
        for item in self {
            let d = try item.traverse(in: order, visitor: visitor)
            if d.halts { return }
        }
    }
    
    public func traverseElements(visitor: (any Tree<Element.Value>) throws -> PreOrderTraversal.Action) rethrows {
        try traverseElements(in: PreOrderTraversal(), visitor: visitor)
    }
    
    public func flattenValues<T: TreeTraversal>(in order: T) -> Array<Element.Value> {
        var flattened = Array<Element.Value>()
        for node in self {
            node.traverse(in: order) {
                flattened.append($0.treeValue)
                return T.Action.keepGoing
            }
        }
        return flattened
    }
    
    public func flattenValues() -> Array<Element.Value> {
        return flattenValues(in: PreOrderTraversal())
    }
    
}

extension TreeTraversal where Self == PreOrderTraversal {
    public static var preOrder: Self { PreOrderTraversal() }
}

extension TreeTraversal where Self == PostOrderTraversal {
    public static var postOrder: Self { PostOrderTraversal() }
}

extension TreeTraversal where Self == BreadthFirstTreeTraversal {
    public static var breadthFirst: Self { BreadthFirstTreeTraversal() }
}
