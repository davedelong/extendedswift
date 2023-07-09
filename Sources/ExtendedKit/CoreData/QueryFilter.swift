//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import CoreData

public protocol QueryFilter: Equatable {
    
    associatedtype ResultType: NSFetchRequestResult
    
    func fetchRequest() -> NSFetchRequest<ResultType>
    
}
