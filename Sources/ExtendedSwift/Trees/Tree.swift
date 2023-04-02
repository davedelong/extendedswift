//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public protocol Tree {
    var children: Array<Self> { get }
    var isLeaf: Bool { get }
}

extension Tree {
    
    public var isLeaf: Bool { return children.isEmpty }
    
}

public protocol BinaryTree: Tree {
    
    var left: Self? { get }
    var right: Self? { get }
    
}

public extension BinaryTree {
    
    var isLeaf: Bool { return left == nil && right == nil }
    
    var children: Array<Self> {
        if let l = left, let r = right { return [l, r] }
        if let l = left { return [l] }
        if let r = right { return [r] }
        return []
    }
    
    var inOrder: Array<Self> { flatten(in: InOrderTraversal()) }
    
}
