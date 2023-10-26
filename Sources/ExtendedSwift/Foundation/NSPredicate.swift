//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/12/23.
//

import Foundation

extension NSPredicate {
    
    public static var `true`: NSPredicate { NSPredicate(value: true) }
    
    public static var `false`: NSPredicate { NSPredicate(value: false) }
    
    public static func and(_ predicates: Array<NSPredicate>) -> NSPredicate {
        switch predicates.count {
            case 0: return .true
            case 1: return predicates[0]
            default: return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
}

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
