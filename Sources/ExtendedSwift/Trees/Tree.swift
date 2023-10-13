//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public protocol Tree<Value> {
    associatedtype Value = Self
    
    var treeValue: Value { get }
    var children: Array<any Tree<Value>> { get }
    var isLeaf: Bool { get }
}

extension Tree {
    
    public var isLeaf: Bool { return children.isEmpty }
    
}

extension Tree where Value == Self {
    
    public var value: Value { self }
    
}

public protocol BinaryTree<Value>: Tree {
    
    var left: (any BinaryTree<Value>)? { get }
    var right: (any BinaryTree<Value>)? { get }
    
}

extension BinaryTree {
    
    public var isLeaf: Bool { return left == nil && right == nil }
    
    public var children: Array<any BinaryTree<Value>> {
        if let l = left, let r = right { return [l, r] }
        if let l = left { return [l] }
        if let r = right { return [r] }
        return []
    }
    
    public var inOrderValues: Array<Value> { flattenValues(in: InOrderTraversal()) }
    
}
