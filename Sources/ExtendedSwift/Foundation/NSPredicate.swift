//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/12/23.
//

import Foundation

extension NSPredicate: Tree {
    
    public typealias Value = NSPredicate
    
    public var treeValue: NSPredicate { self }
    
    public var children: Array<any Tree<NSPredicate>> {
        if let compound = self as? NSCompoundPredicate {
            return compound.subpredicates as! Array<NSPredicate>
        }
        return []
    }
    
}
