//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation

public protocol Fetchable {
    associatedtype Filter: FetchFilter
    
    init(result: Filter.ResultType)
}
