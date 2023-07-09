//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation

public protocol Queryable {
    associatedtype Filter: QueryFilter
    
    init(result: Filter.ResultType)
}
